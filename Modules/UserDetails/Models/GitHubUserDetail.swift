//
//  GitHubUserDetail.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

struct GitHubUserDetail: Codable {
    let id: Int
    let nameLogin: String
    let avatarUrl: String
    let htmlUrl: String
    let location: String
    let followers: Int
    let following: Int
    // Mapping giữa tên khóa JSON và tên thuộc tính trong struct
    enum CodingKeys: String, CodingKey {
        case id
        case nameLogin = "login"
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case location
        case followers
        case following
    }
}
