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
    private var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserService
    private let coreDataHelper: CoreDataHelper
    
    init(userService: UserService, coreDataHelper: CoreDataHelper) {
        self.userService = userService
        self.coreDataHelper = coreDataHelper
    }
    
    func fetchUserList() {
        // neu lan dau
        // Check if already loading
        guard !isLoading else { return }
        
        isLoading = true
        Task {
            do {
                // Fetch new users from the service
                let newUsers = try await userService.fetchUsers(perPage: perPage, since: since)
                print("debug user from api \(newUsers.debugDescription)")
                // Store the new users in Core Data
                try await coreDataHelper.storeUserList(newUsers)
                
                // Update the 'since' value for pagination
                self.since = newUsers.last?.id ?? self.since
                
                // Fetch the cached users from Core Data
                let cachedUsers = try await self.coreDataHelper.fetchUserList()
                print("debug cache user \(cachedUsers.count)")
                // Map cached users to view models
                let viewModels = cachedUsers.map { UserInfoViewModel(name: $0.nameLogin,
                                                                     avatar: $0.avatarUrl,
                                                                     url: $0.htmlUrl) }
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.users.value = viewModels
                }
            } catch {
                // Handle errors
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
            
            // Reset isLoading flag on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func refreshUserList() {
        Task {
            do {
                // Delete all users in Core Data
                try await coreDataHelper.deleteAllUserList()
                
                // Reset 'since' value
                self.since = 0
                
                // Fetch the new user list
                await fetchUserList()
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    func loadUsersFromCoreData() async {
        do {
            // Fetch cached users
            let cachedUsers = try await coreDataHelper.fetchUserList()
            
            // Map cached users to view models
            let viewModels = cachedUsers.map { UserInfoViewModel(name: $0.nameLogin,
                                                                 avatar: $0.avatarUrl,
                                                                 url: $0.htmlUrl) }
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.users.value = viewModels
            }
            
            // If no cached users, fetch from the service
            if cachedUsers.isEmpty {
                 fetchUserList()
            }
        } catch {
            // Handle errors if any
            DispatchQueue.main.async {
                self.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet:
                print("No internet connection")
            case .timeout:
                print("Request timed out")
            case .serverError(let message):
                print("Server error: \(message)")
            default:
                print("Unknown error")
            }
        } else {
            print("Error: \(error.localizedDescription)")
        }
    }
}
