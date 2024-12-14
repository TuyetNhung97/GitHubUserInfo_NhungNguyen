//
//  ResponseHandler.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

class ResponseHandler {
    func handleResponse<T: Codable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<T, NetworkError> {
        if let error = error {
            return .failure(NetworkError.serverError(error.localizedDescription))
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return .failure(NetworkError.serverError("Invalid status code"))
        }
        
        guard let data = data else {
            return .failure(NetworkError.unknown)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(NetworkError.decodingError)
        }
    }
}
