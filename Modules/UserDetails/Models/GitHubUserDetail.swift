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
    let location: String
    let followerNumber: Int
    let followingNumber: Int
    let blogUrl: String
    // Mapping giữa tên khóa JSON và tên thuộc tính trong struct
    enum CodingKeys: String, CodingKey {
        case id
        case nameLogin = "login"
        case avatarUrl = "avatar_url"
        case location
        case followerNumber = "followers"
        case followingNumber = "following"
        case blogUrl = "blog"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.nameLogin = try container.decode(String.self, forKey: .nameLogin)
        self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        self.location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        self.followerNumber = try container.decode(Int.self, forKey: .followerNumber)
        self.followingNumber = try container.decode(Int.self, forKey: .followingNumber)
        self.blogUrl = try container.decodeIfPresent(String.self, forKey: .blogUrl) ?? ""
    }
}
