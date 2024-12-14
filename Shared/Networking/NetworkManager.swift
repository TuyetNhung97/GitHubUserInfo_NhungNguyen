//
//  NetworkManager.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import Foundation

class NetworkManager: NetworkServiceProtocol {

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
            // Tạo request từ Endpoint
            let request = try endpoint.asURLRequest()

            // Thực hiện request với retry policy
            return try await retryPolicy.execute {
                try await self.performRequest(request: request)
            }
        } catch {
            // Quản lý lỗi nếu có
            throw error as? NetworkError ?? .unknown
        }
    }

    private func performRequest<T: Codable>(request: URLRequest) async throws -> T {
        do {
            // Thực hiện API call với async/await
            let (data, response) = try await session.data(for: request)

            // Kiểm tra response và parse JSON
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError("Invalid status code")
            }

            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            // Xử lý lỗi từ URLSession hoặc parsing
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

