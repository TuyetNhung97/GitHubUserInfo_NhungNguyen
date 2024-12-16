//
//  GitHubUser.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

struct GitHubUser: Codable {
    let id: Int
    let nameLogin: String
    let avatarUrl: String
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameLogin = "login"
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}
