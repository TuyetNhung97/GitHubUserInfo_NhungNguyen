//
//  NetworkError.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

enum NetworkError: Error {
    case noInternet
    case invalidURL
    case timeout
    case serverError(String)
    case decodingError
    case unknown
}
