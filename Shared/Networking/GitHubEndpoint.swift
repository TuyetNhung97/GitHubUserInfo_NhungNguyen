//
//  GitHubEndpoint.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Endpoint {
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [URLQueryItem]? { get }
    func asURLRequest() throws -> URLRequest

}

enum GitHubEndpoint: Endpoint {
    case fetchUsers(perPage: Int, since: Int)
    case fetchUserDetail(loginUsername: String)
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }
    var timeout: TimeInterval {
        return 60
    }

    var baseURL: String {
        return "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .fetchUsers:
            return "/users"
        case .fetchUserDetail(let loginUsername):
            return "/users/\(loginUsername)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUsers:
            return .get
        case .fetchUserDetail:
            return .get
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        case .fetchUsers(let perPage, let since):
            return [
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "since", value: "\(since)")
            ]
        case .fetchUserDetail:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = parameters
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        print(request)
        return request
    }
}
