//
//  UserListVMTests.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import XCTest
@testable import GitHubUserInfo_NhungNguyen

final class UserListVMTests: XCTestCase {
    var sut: UserListVM!
    var mockUserService: MockAPIService!
    var mockCoreDataHelper: MockCoreDataHelper!
    
    override func setUp() {
        super.setUp()
        mockUserService = MockAPIService()
        mockCoreDataHelper = MockCoreDataHelper()
        sut = UserListVMImpl(userService: mockUserService,
                             coreDataHelper: mockCoreDataHelper)
    }
    
    override func tearDown() {
        sut = nil
        mockUserService = nil
        mockCoreDataHelper = nil
        super.tearDown()
    }
    
    func testFetchUserList_Success() async {
        // Arrange
        let users = [
            GitHubUser(id: 1,
                       nameLogin: "Nguyen Van A",
                       avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
                       htmlUrl: "https://github.com/jvantuyl"),
            GitHubUser(id: 2,
                       nameLogin: "Nguyen Van B",
                       avatarUrl: "https://avatars.githubusercontent.com/u/101?v=6",
                       htmlUrl: "https://github.com/BrianTheCoder")
        ]
        mockUserService.mockUsers = users
        
        // Act
        sut.fetchUserList()
        await Task.sleep(500_000_000)

        // Assert
        XCTAssertEqual(sut.users.value.count, users.count)
        XCTAssertEqual(sut.users.value.first?.name, users.first?.nameLogin)
        XCTAssertEqual(sut.users.value.last?.name, users.last?.nameLogin)
    }
    
    func testFetchUserList_Error() async {
        // Arrange
        mockUserService.shouldReturnError = true
        
        // Act
        sut.fetchUserList()
        await Task.sleep(500_000_000)
        
        // Assert
        XCTAssertTrue(sut.users.value.isEmpty)
    }
    
    func testLoadUsersFromCoreData_NoCachedUsers() async {
        // Arrange
        mockCoreDataHelper.mockCachedUsers = []
        let apiuUsers = [
            GitHubUser(id: 1, nameLogin: "User1", avatarUrl: "url1", htmlUrl: "html1"),
            GitHubUser(id: 1, nameLogin: "User1", avatarUrl: "url1", htmlUrl: "html1")
        ]
        mockUserService.mockUsers = apiuUsers
        
        // Act
        await sut.loadUsersFromCoreData()
        await Task.sleep(500_000_000)
        
        // Assert
        XCTAssertEqual(sut.users.value.count, 2)
        XCTAssertEqual(sut.users.value.first?.name, "User1")
    }
    
    func testLoadUsersFromCoreData_WithCachedUsers() async {
        // Arrange
        let cachedUsers = [
            GitHubUser(id: 1, nameLogin: "CachedUser1", avatarUrl: "cachedUrl1", htmlUrl: "cachedHtml1")
        ]
        mockCoreDataHelper.mockCachedUsers = cachedUsers
        
        // Act
        await sut.loadUsersFromCoreData()
        
        // Assert
        XCTAssertEqual(sut.users.value.count, cachedUsers.count)
        XCTAssertEqual(sut.users.value.first?.name, "CachedUser1")
    }
    
    func testRefreshUserList_Success() async {
        // Arrange
        let users = [
            GitHubUser(id: 1, nameLogin: "User1", avatarUrl: "url1", htmlUrl: "html1")
        ]
        mockUserService.mockUsers = users
        
        // Act
        sut.refreshUserList()
        await Task.sleep(500_000_000)
        
        // Assert
        XCTAssertEqual(sut.users.value.count, users.count)
        XCTAssertEqual(sut.users.value.first?.name, "User1")
    }
}
