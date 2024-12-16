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
    var mockUserDetail: GitHubUserDetail?
    
    func fetchUsers(perPage: Int, since: Int) async throws -> [GitHubUser] {
        if shouldReturnError {
            throw NetworkError.serverError("Test Error")
        }
        return mockUsers
    }
    
    func fetchUserDetail(loginUsername: String) async throws -> GitHubUserDetail {
        if shouldReturnError {
            throw NetworkError.serverError("Test Error")
        }
        return mockUserDetail ?? GitHubUserDetail(id: 1,
                                                  nameLogin: "NhungNguyen",
                                                  avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
                                                  location: "Viet Nam",
                                                  followerNumber: 100000,
                                                  followingNumber: 100000,
                                                  blogUrl: "http://souja.net")
    }
}


