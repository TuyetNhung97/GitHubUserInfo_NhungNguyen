//
//  UserEntity.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var nameLogin: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var htmlUrl: String?
}

extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
}

// Core Data Model Programmatic Setup
extension NSManagedObjectModel {
    static func createUserEntityModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // UserEntity Description
        let userEntity = NSEntityDescription()
        userEntity.name = "UserEntity"
        userEntity.managedObjectClassName = NSStringFromClass(UserEntity.self)

        // Attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .integer64AttributeType
        idAttribute.isOptional = false

        let nameLoginAttribute = NSAttributeDescription()
        nameLoginAttribute.name = "nameLogin"
        nameLoginAttribute.attributeType = .stringAttributeType
        nameLoginAttribute.isOptional = true

        let avatarUrlAttribute = NSAttributeDescription()
        avatarUrlAttribute.name = "avatarUrl"
        avatarUrlAttribute.attributeType = .stringAttributeType
        avatarUrlAttribute.isOptional = true

        let htmlUrlAttribute = NSAttributeDescription()
        htmlUrlAttribute.name = "htmlUrl"
        htmlUrlAttribute.attributeType = .stringAttributeType
        htmlUrlAttribute.isOptional = true

        // Set Attributes
        userEntity.properties = [idAttribute, nameLoginAttribute, avatarUrlAttribute, htmlUrlAttribute]

        // Add Entity to Model
        model.entities = [userEntity]

        return model
    }
}

// Example Persistent Container with Programmatically Created Model
extension NSPersistentContainer {
    static func createUserEntityContainer() -> NSPersistentContainer {
        let model = NSManagedObjectModel.createUserEntityModel()
        let container = NSPersistentContainer(name: "GitHubUsersModel", managedObjectModel: model)

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        return container
    }
}

