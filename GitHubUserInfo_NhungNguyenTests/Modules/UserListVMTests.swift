//
//  UserListVMTests.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import XCTest
import Combine
@testable import GitHubUserInfo_NhungNguyen

final class UserListVMTests: XCTestCase {
    private var viewModel: UserListVM!
    private var mockUserService: MockAPIService!
    private var mockCoreDataHelper: MockCoreDataHelper!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        self.mockUserService = MockAPIService()
        self.mockCoreDataHelper = MockCoreDataHelper()
        self.viewModel = UserListVMImpl(userService: mockUserService,
                                   coreDataHelper: mockCoreDataHelper)
        self.cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        self.viewModel = nil
        self.mockUserService = nil
        self.mockCoreDataHelper = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    func testFetchUserList_Success() async {
        let mockUsers = [GitHubUser(id: 3,
                                    nameLogin: "NhungNguyen",
                                    avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
                                    htmlUrl: "http://souja.net")]
        mockUserService.mockUsers = mockUsers
        mockCoreDataHelper.mockUserList = []
        
        let expectation = self.expectation(description: "Users should be updated")
        viewModel.users
            .sink { users in
                if !users.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchUserList()
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.users.value.count, 1)
        XCTAssertEqual(viewModel.users.value.first?.name, "NhungNguyen")
    }
    
    func testFetchUserList_Failure() async {
        mockUserService.shouldReturnError = true
        
        viewModel.fetchUserList()
        
        let expectation = self.expectation(description: "Error should be emitted")
        var receivedError: String?
        
        viewModel.errorPublisher
            .sink { errorMessage in
                receivedError = errorMessage
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(receivedError, "Server issue - Test Error", "Expected error was not emitted")
    }
    
    func testLoadUsersFromCoreData() async throws {
        let mockUsers = [GitHubUser(
            id: 3,
            nameLogin: "NguyenNhung",
            avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
            htmlUrl: "http://souja.net"
        )]
        mockCoreDataHelper.mockUserList = []
        try await mockCoreDataHelper.storeUserList(mockUsers)

        await viewModel.loadUsersFromCoreData()

        let users = viewModel.users.value
        XCTAssertEqual(users.count, 1, "Expected exactly 1 user to be loaded from Core Data")
        XCTAssertEqual(users.first?.name, "NguyenNhung", "User name should match the mock data")
    }
}
