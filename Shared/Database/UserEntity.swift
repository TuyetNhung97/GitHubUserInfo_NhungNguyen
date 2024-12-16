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
    @NSManaged public var nameLogin: String
    @NSManaged public var avatarUrl: String
    @NSManaged public var htmlUrl: String
}

extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
}

extension NSManagedObjectModel {
    static func createUserEntityModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let userEntity = NSEntityDescription()
        userEntity.name = "UserEntity"
        userEntity.managedObjectClassName = NSStringFromClass(UserEntity.self)
        
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
        
        userEntity.properties = [idAttribute, nameLoginAttribute, avatarUrlAttribute, htmlUrlAttribute]
        
        model.entities = [userEntity]
        
        return model
    }
}

extension UserEntity {
    convenience init(context: NSManagedObjectContext, user: GitHubUser) {
        self.init(context: context)
        self.id = Int64(user.id)
        self.nameLogin = user.nameLogin
        self.avatarUrl = user.avatarUrl
        self.htmlUrl = user.htmlUrl
    }
}

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

