//
//  RequestBuilder.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

//class RequestBuilder {
//    
//    func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
//        guard let url = URL(string: baseURL + endpoint.path) else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url, cachePolicy: endpoint.cachePolicy, timeoutInterval: endpoint.timeout)
//        request.httpMethod = endpoint.method.rawValue
//        
//        // Add headers
//        if let headers = endpoint.headers {
//            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
//        }
//        
//        // Add parameters
//        if let parameters = endpoint.parameters {
//            switch endpoint.method {
//            case .get:
//                var urlComponents = URLComponents(string: baseURL + endpoint.path)
//                urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
//                request.url = urlComponents?.url
//            default:
//                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            }
//        }
//        
//        return request
//    }
//}
