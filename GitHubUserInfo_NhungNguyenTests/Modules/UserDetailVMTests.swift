//
//  UserDetailViewModelTests.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import XCTest
import Combine
@testable import GitHubUserInfo_NhungNguyen

final class UserDetailViewModelTests: XCTestCase {
    
    private var viewModel: UserDetailVM!
    private var mockUserService: MockAPIService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockUserService = MockAPIService()
        viewModel = UserDetailVMImpl(userService: mockUserService, loginUsername: "NhungNguyen")
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchUserDetail_Success() async {
        let mockUserDetail = GitHubUserDetail(
            id: 1,
            nameLogin: "NhungNguyen",
            avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
            location: "Viet Nam",
            followerNumber: 120,
            followingNumber: 5,
            blogUrl: "http://souja.net"
        )
        mockUserService.mockUserDetail = mockUserDetail
        
        viewModel.fetchUserDetail()
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let userDetail = viewModel.userDetail.value
        XCTAssertNotNil(userDetail, "User detail should not be nil")
        XCTAssertEqual(userDetail?.userGeneralInfo.name, "NhungNguyen")
        XCTAssertEqual(userDetail?.followerNumber.getFormattedString(), "100+")
        XCTAssertEqual(userDetail?.followingNumber.getFormattedString(), "5")
    }
    
    func testFetchUserDetail_Failure() async {
        mockUserService.shouldReturnError = true
        
        viewModel.fetchUserDetail()
        
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
    
    
    func testFollowTypeFormatting() {
        let testCases: [(FollowType, String)] = [
            (.follower(120), "100+"),
            (.follower(50), "50"),
            (.following(5), "5"),
            (.following(15), "10+")
        ]
        
        for (followType, expectedString) in testCases {
            XCTAssertEqual(followType.getFormattedString(), expectedString, "FollowType formatting is incorrect")
        }
    }
}


