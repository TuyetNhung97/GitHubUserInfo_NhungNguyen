//
//  UserSevice.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

protocol UserService {
    func fetchUsers(perPage: Int, since: Int) async throws -> [GitHubUser]
    func fetchUserDetail(loginUsername: String) async throws -> GitHubUserDetail
}

class UserSeviceIml: UserService {
    private let apiService: NetworkService
    
    init(apiService: NetworkService) {
        self.apiService = apiService
    }

    func fetchUsers(perPage: Int, since: Int) async throws -> [GitHubUser] {
        return try await apiService.request(GitHubEndpoint.fetchUsers(perPage: perPage, since: since))
    }
    
    func fetchUserDetail(loginUsername: String) async throws -> GitHubUserDetail {
        return try await apiService.request(GitHubEndpoint.fetchUserDetail(loginUsername: loginUsername))
    }
    
    
}
