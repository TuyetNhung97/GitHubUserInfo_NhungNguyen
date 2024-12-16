//
//  CoreDataHelperProtocol.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import Foundation

protocol CoreDataHelper {
    func fetchUserList() async throws -> [UserEntity]
    func storeUserList(_ users: [GitHubUser]) async throws
    func deleteAllUserList() async throws
}
