//
//  UserListVM.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import Foundation
import Combine

protocol UserListVM {
    var users: CurrentValueSubject<[UserInfoViewModel], Never> { get }
    var perPage: Int { get }
    var since: Int { get set }
    var errorPublisher: PassthroughSubject<String, Never> { get }
    func fetchUserList()
    func refreshUserList()
    func loadUsersFromCoreData() async
}

class UserListVMImpl: UserListVM {
    // MARK: - Properties
    @Published var users = CurrentValueSubject<[UserInfoViewModel], Never>([])
    let perPage = 20
    var since = 0
    private var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserService
    private let coreDataHelper: CoreDataHelper
    var errorPublisher = PassthroughSubject<String, Never>()
    
    // MARK: - Initializer
    init(userService: UserService, coreDataHelper: CoreDataHelper) {
        self.userService = userService
        self.coreDataHelper = coreDataHelper
    }
    
    // MARK: - Public Methods
    func fetchUserList() {
        // Prevent multiple concurrent API requests by checking if a request is already in progress.
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let newUsers = try await userService.fetchUsers(perPage: perPage, since: since)
                try await coreDataHelper.storeUserList(newUsers)
                since = newUsers.last?.id ?? since
                await updateViewModelsFromCoreData()
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    func refreshUserList() {
        Task {
            do {
                try await coreDataHelper.deleteAllUserList()
                since = 0
                fetchUserList()
            } catch {
                handleError(error)
            }
        }
    }
    
    func loadUsersFromCoreData() async {
        await updateViewModelsFromCoreData()
        
        if users.value.isEmpty {
            fetchUserList()
        }
    }
    
    // MARK: - Private Methods
    /// Updates the users view model from cached Core Data users.
    private func updateViewModelsFromCoreData() async {
        do {
            let cachedUsers = try await coreDataHelper.fetchUserList()
            since = Int(cachedUsers.last?.id ?? Int64(since))
            users.value = cachedUsers.mapToViewModels()
        } catch {
            handleError(error)
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

// MARK: - Extensions
private extension Array where Element == UserEntity {
    func mapToViewModels() -> [UserInfoViewModel] {
        return self.map { UserInfoViewModel(name: $0.nameLogin, avatar: $0.avatarUrl, url: $0.htmlUrl) }
    }
}

