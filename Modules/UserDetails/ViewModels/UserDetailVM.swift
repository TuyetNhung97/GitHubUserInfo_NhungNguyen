//
//  UserDetailVM.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 15/12/24.
//

import Foundation
import Combine

protocol UserDetailVM {
    var userDetail: CurrentValueSubject<UserDetailViewModel?, Never> { get set }
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
    
    private let userService: UserService
    private let loginUsername: String
    var userDetail = CurrentValueSubject<UserDetailViewModel?, Never>(nil)
    
    init(userService: UserService, loginUsername: String) {
        self.userService = userService
        self.loginUsername = loginUsername
    }
    
    func fetchUserDetail() {
        Task { [weak self] in
            guard let self = self else { return }
            let userDetailInfo: GitHubUserDetail = try await userService.fetchUserDetail(loginUsername: self.loginUsername)
            userDetail.value = UserDetailViewModel(userGeneralInfo: UserInfoViewModel(name: userDetailInfo.nameLogin,
                                                                                      avatar: userDetailInfo.avatarUrl,
                                                                                      location: userDetailInfo.location),
                                                   followerNumber: FollowType.follower(userDetailInfo.followerNumber),
                                                   followingNumber: FollowType.following(userDetailInfo.followingNumber),
                                                   blogUrl: userDetailInfo.blogUrl)
        }
    }
}
