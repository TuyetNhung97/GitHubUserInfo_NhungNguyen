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
    
    static var defaultContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubUsersModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    func fetchUserList() async throws -> [UserEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }
    
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
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)
                    
                    try context.save()
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
