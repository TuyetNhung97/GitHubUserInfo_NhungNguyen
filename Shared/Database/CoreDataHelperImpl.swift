//
//  CoreDataHelperImpl.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import Foundation
import CoreData

class CoreDataHelperImpl: CoreDataHelper {
    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }

    // Default Persistent Container
    static var defaultContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubUsersModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()

    // Fetch User List
    func fetchUserList() async throws -> [GitHubUser] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

        do {
            let results = try await context.fetch(fetchRequest)
            return results.map { userEntity in
                GitHubUser(
                    id: Int(userEntity.id),
                    nameLogin: userEntity.nameLogin ?? "",
                    avatarUrl: userEntity.avatarUrl ?? "",
                    htmlUrl: userEntity.htmlUrl ?? ""
                )
            }
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }

    // Store User List
    func storeUserList(_ users: [GitHubUser]) async throws {
        let context = persistentContainer.viewContext

        for user in users {
            let userEntity = UserEntity(context: context)
            userEntity.id = Int64(user.id)
            userEntity.nameLogin = user.nameLogin
            userEntity.avatarUrl = user.avatarUrl
            userEntity.htmlUrl = user.htmlUrl
        }

        do {
            try await context.save()
        } catch {
            print("Failed to save users: \(error)")
        }
    }
// Fetch Single User by ID
    func fetchUser(by id: Int) async throws -> GitHubUser? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            if let userEntity = try await context.fetch(fetchRequest).first {
                return GitHubUser(
                    id: Int(userEntity.id),
                    nameLogin: userEntity.nameLogin ?? "",
                    avatarUrl: userEntity.avatarUrl ?? "",
                    htmlUrl: userEntity.htmlUrl ?? ""
                )
            }
        } catch {
            print("Failed to fetch user by ID: \(error)")
        }
        return nil
    }
}
