//
//  NetworkServiceProtocol.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import Foundation

protocol NetworkService {
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T
}
