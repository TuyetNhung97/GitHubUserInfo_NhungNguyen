//
//  NetworkManager.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import Foundation

class NetworkServiceImpl: NetworkService {
    
    private let responseHandler: ResponseHandler
    private let retryPolicy: RetryPolicy
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared,
         retryPolicy: RetryPolicy = RetryPolicy()) {
        self.responseHandler = ResponseHandler()
        self.retryPolicy = retryPolicy
        self.session = session
    }
    
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T {
        do {
            let request = try endpoint.asURLRequest()
            
            return try await retryPolicy.execute {
                try await self.performRequest(request: request)
            }
        } catch {
            throw error as? NetworkError ?? .unknown
        }
    }
    
    private func performRequest<T: Codable>(request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError("Invalid status code")
            }
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw handleError(error)
        }
    }
    
    private func handleError(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternet
            case .timedOut:
                return .timeout
            default:
                return .serverError(urlError.localizedDescription)
            }
        }
        return .unknown
    }
}

