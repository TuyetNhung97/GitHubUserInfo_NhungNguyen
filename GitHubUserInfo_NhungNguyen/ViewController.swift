//
//  ViewController.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import UIKit

class ViewController: UIViewController {
    private let networkManager = NetworkManager()
    private var users: GitHubUserDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "GitHub Users"
        
        Task {
            do {
                // Fetch danh sách người dùng với async/await
                users = try await networkManager.request(GitHubEndpoint.fetchUserDetail(loginUsername: "mojombo"))
                print("Fetched users: \(users)")
            } catch {
                handleError(error)
            }
        }
        
        let v = UserCardView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.configure(with: UserInfoViewModel(name: "Nhung",
                                            avatar: "https://avatars.githubusercontent.com/u/1?v=4",
                                            location: "Việt Nam",
                                            url: "https://github.com/mojombo"))
        view.addSubview(v)
        v.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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


