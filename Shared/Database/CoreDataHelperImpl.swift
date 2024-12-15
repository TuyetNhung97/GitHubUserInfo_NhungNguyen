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
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        do {
            let results = try context.fetch(fetchRequest)
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
            try context.performAndWait {
                try context.save()
            }
           
        } catch {
            print("Failed to save users: \(error)")
        }
    }
    
    func deleteAllUserList() async throws {
        
        try await withCheckedThrowingContinuation { continuation in
            let context = persistentContainer.viewContext
                context.performAndWait {
                    do {
                        // Create a fetch request to delete all objects in the entity
                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        // Perform the batch delete request
                        try context.execute(deleteRequest)
                        
                        // Optionally save the context (if needed after deletion)
                        try context.save()
                        
                        continuation.resume()  // Success, resume continuation
                    } catch {
                        continuation.resume(throwing: error)  // Handle any error and resume with the error
                    }
                }
            }
    }
    
}
