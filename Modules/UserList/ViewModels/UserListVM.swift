//
//  UserListVM.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation
import Combine

protocol UserListVM {
    var users: CurrentValueSubject<[UserInfoViewModel], Never> { get set }
    var perPage: Int { get }
    var since: Int { get set }
    func fetchUserList()
    func refreshUserList()
    func loadUsersFromCoreData() async
}

class UserListVMImpl: UserListVM {
    @Published var users = CurrentValueSubject<[UserInfoViewModel], Never>([])
    let perPage = 20
    var since = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserSevice
    private let coreDataHelper: CoreDataHelper
    
    init(userService: UserSevice, coreDataHelper: CoreDataHelper) {
        self.userService = userService
        self.coreDataHelper = coreDataHelper
    }
    
    func fetchUserList() {
        Task {
            do {
                let newUsers = try await userService.fetchUsers(perPage: perPage, since: since)
                let _ = try await self.coreDataHelper.storeUserList(newUsers)
                self.since = newUsers.last?.id ?? self.since
                let viewModels = newUsers.map { UserInfoViewModel(name: $0.nameLogin,
                                                                  avatar: $0.avatarUrl,
                                                                  url: $0.htmlUrl)}
                self.users.value.append(contentsOf: viewModels)
            }
            catch {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshUserList() {
        self.since = 0
        self.fetchUserList()
    }
        
    func loadUsersFromCoreData() async {
        Task {
            do {
                let cachedUsers = try await coreDataHelper.fetchUserList()
                let viewModels = cachedUsers.map { UserInfoViewModel(name: $0.nameLogin,
                                                                     avatar: $0.avatarUrl,
                                                                     url: $0.htmlUrl)}
                self.users.value = viewModels
                if cachedUsers.isEmpty {
                    fetchUserList()
                }
            } catch {
                
            }
        }
    }
}
