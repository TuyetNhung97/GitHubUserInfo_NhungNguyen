//
//  MockAPIService.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import Foundation

@testable import GitHubUserInfo_NhungNguyen
class MockAPIService: UserService {
    
    var shouldReturnError = false
    var mockUsers: [GitHubUser] = []
    
    func fetchUsers(perPage: Int, since: Int) async throws -> [GitHubUser] {
        if shouldReturnError {
            throw NetworkError.serverError("Mock error")
        }
        return mockUsers
    }
    
    func fetchUserDetail(loginUsername: String) async throws -> GitHubUserDetail {
        return GitHubUserDetail(id: 0,
                                nameLogin: "",
                                avatarUrl: "",
                                location: "",
                                followerNumber: 0,
                                followingNumber: 0,
                                blogUrl: "")
    }
    
}
