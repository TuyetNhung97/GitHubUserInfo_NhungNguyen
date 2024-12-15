//
//  MockCoreDataHelper.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import Foundation

@testable import GitHubUserInfo_NhungNguyen
class MockCoreDataHelper: CoreDataHelper {
    var shouldReturnError = false
    var mockCachedUsers: [GitHubUser] = []
    
    func storeUserList(_ users: [GitHubUser]) async throws {
        if shouldReturnError {
          
            throw NSError(domain: "CoreDataError", code: 1, userInfo: nil)
        }
        mockCachedUsers = users
    }
    
    func fetchUserList() async throws -> [GitHubUser] {
        if shouldReturnError {
            throw NSError(domain: "CoreDataError", code: 1, userInfo: nil)
        }
        return mockCachedUsers
    }
    
    func deleteAllUserList() async throws {
        if shouldReturnError {
            throw NSError(domain: "CoreDataError", code: 1, userInfo: nil)
        }
        mockCachedUsers = []
    }
}
