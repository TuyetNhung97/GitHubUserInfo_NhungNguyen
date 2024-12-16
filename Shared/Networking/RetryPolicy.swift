//
//  RetryPolicy.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation

class RetryPolicy {
    private let maxRetryCount: Int
    private let delay: TimeInterval
    
    init(maxRetryCount: Int = 3, delay: TimeInterval = 2.0) {
        self.maxRetryCount = maxRetryCount
        self.delay = delay
    }
    
    func execute<T>(operation: @escaping () async throws -> T) async throws -> T {
        var currentRetryCount = 0
        
        while currentRetryCount < maxRetryCount {
            do {
                return try await operation()
            } catch {
                currentRetryCount += 1
                
                if currentRetryCount >= maxRetryCount {
                    throw error
                }
                
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        throw NetworkError.unknown
    }
}
