//
//  UserDetailViewModelTests.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import XCTest
import Combine
@testable import GitHubUserInfo_NhungNguyen

class UserDetailViewModelTests: XCTestCase {
    var sut: UserDetailVM!
    var mockUserService: MockAPIService!
    var loginUsername: String = ""
    
    
    override func setUp() {
        super.setUp()
        self.mockUserService = MockAPIService()
        self.loginUsername = "NhungNguyen"
        self.sut = UserDetailVMImpl(userService: self.mockUserService,
                                    loginUsername: loginUsername)
        self.cancellables = []
    }
    
    override func tearDown() {
        self.mockUserService = nil
        self.sut = nil
        self.loginUsername = ""
        self.cancellables = nil
        super.tearDown()
    }
    
    // Test: Fetch User Detail Successfully
    func testFetchUserDetail_Success() {
        mockUserService.mockUserDetail = GitHubUserDetail(
            nameLogin: "JohnDoe",
            avatarUrl: "https://example.com/avatar.jpg",
            location: "San Francisco",
            followerNumber: 150,
            followingNumber: 20,
            blogUrl: "https://johndoe.com"
        )
        
        // Fetch user details
        Task {
            await sut.fetchUserDetail()
        }
        
        XCTAssertEqual(sut.userGeneralInfo.name, mockUserService.mockUserDetail?.nameLogin)
        XCTAssertEqual(sut.userGeneralInfo.location, mockUserService.mockUserDetail?.location)
        XCTAssertEqual(sut.followerNumber.getFormattedString(), "100+")
        XCTAssertEqual(sut.followingNumber.getFormattedString(), "10+")
    }
    
    // Test: Fetch User Detail with Error
    func testFetchUserDetail_Error() {
        mockUserService.shouldReturnError = true
        
        // Test that calling fetchUserDetail throws an error
        await XCTAssertThrowsError(try await sut.fetchUserDetail()) { error in
            // You can add more assertions on the error if needed
            XCTAssertEqual((error as? NSError)?.code, 500, "Expected network error code 500")
            XCTAssertEqual((error as? NSError)?.localizedDescription, "Network error", "Expected network error description")
        }
    }
}
