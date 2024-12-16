//
//  UserDetailVM.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 15/12/24.
//

import Foundation
import Combine

protocol UserDetailVM {
    var userDetail: CurrentValueSubject<UserDetailViewModel?, Never> { get }
    var errorPublisher: PassthroughSubject<String, Never> { get }
    func fetchUserDetail()
}

enum FollowType {
    case follower(_ number: Int)
    case following(_ number: Int)
    
    func getFormattedString() -> String {
        switch self {
        case let .follower(number):
            return number > 100 ? "100+" : "\(number)"
        case let .following(number):
            return number > 10 ? "10+" : "\(number)"
        }
    }
}

class UserDetailVMImpl: UserDetailVM {
    
    // MARK: - Properties
    private let userService: UserService
    private let loginUsername: String
    var userDetail = CurrentValueSubject<UserDetailViewModel?, Never>(nil)
    var errorPublisher = PassthroughSubject<String, Never>()
    
    // MARK: - Initializer
    init(userService: UserService, loginUsername: String) {
        self.userService = userService
        self.loginUsername = loginUsername
    }
    
    // MARK: - Public Methods
    func fetchUserDetail() {
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let userDetailInfo: GitHubUserDetail = try await userService.fetchUserDetail(loginUsername: self.loginUsername)
                userDetail.value = UserDetailViewModel(
                    userGeneralInfo: UserInfoViewModel(
                        name: userDetailInfo.nameLogin,
                        avatar: userDetailInfo.avatarUrl,
                        location: userDetailInfo.location
                    ),
                    followerNumber: FollowType.follower(
                        userDetailInfo.followerNumber
                    ),
                    followingNumber: FollowType.following(
                        userDetailInfo.followingNumber
                    ),
                    blogUrl: userDetailInfo.blogUrl
                )
            } catch {
                self.handleError(error)
            }
        }
    }
    
    /// Handles errors and provides appropriate logs or feedback.
    private func handleError(_ error: Error) {
        var errorMessage = "An error occurred"
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet:
                errorMessage = "No internet connection"
            case .timeout:
                errorMessage = "Request timed out"
            case .serverError(let message):
                errorMessage = "Server issue - \(message)"
            default:
                errorMessage = "Unknown network issue"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        // Send the error message to the subscribers
        errorPublisher.send(errorMessage)
    }
}

