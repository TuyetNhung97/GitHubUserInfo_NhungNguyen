//
//  MockCoreDataHelper.swift
//  GitHubUserInfo_NguyenThiTuyetNhung
//
//  Created by Nguyen Jenny on 12/12/24.
//

import Foundation
import CoreData
@testable import GitHubUserInfo_NhungNguyen

class MockCoreDataHelper: CoreDataHelper {
    var shouldReturnError = false
    var mockUserList: [UserEntity] = []

    let persistentContainer: NSPersistentContainer = .createUserEntityContainer()
    
    func storeUserList(_ users: [GitHubUser]) async throws {
        if shouldReturnError {
            throw NSError(domain: "CoreData", code: 0, userInfo: nil)
        }
        mockUserList = users.map { UserEntity(context: persistentContainer.viewContext, user: $0) }
    }
    
    func fetchUserList() async throws -> [UserEntity] {
        if shouldReturnError {
            throw NSError(domain: "CoreData", code: 0, userInfo: nil)
        }
        return mockUserList
    }
    
    func deleteAllUserList() async throws {
        if shouldReturnError {
            throw NSError(domain: "CoreData", code: 0, userInfo: nil)
        }
        mockUserList.removeAll()
    }
}

private extension Array where Element == GitHubUser {
    func toUserEntities(in context: NSManagedObjectContext) -> [UserEntity] {
        return self.map { githubUser in
            return UserEntity(context: context, user: githubUser)
        }
    }
}
