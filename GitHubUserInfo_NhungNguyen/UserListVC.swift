//
//  UserListVC.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import UIKit

class UserListVC: UIViewController {
    
    private let networkManager = NetworkManager()
    private var users: [GitHubUser] = []
    private lazy var userListTbl: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UserListItemCell.self, forCellReuseIdentifier: UserListItemCell.reuseIdentifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
//        view.backgroundColor = .white
//        title = "GitHub Users"
//        
        Task {
            do {
                // Fetch danh sách người dùng với async/await
                users = try await networkManager.request(GitHubEndpoint.fetchUsers(perPage: 20, since: 0))
                userListTbl.reloadData()
            } catch {
                handleError(error)
            }
        }
//        
//        let v = UserCardView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.configure(with: UserInfoViewModel(name: "Nhung",
//                                            avatar: "https://avatars.githubusercontent.com/u/1?v=4",
//                                            location: "Việt Nam",
//                                            url: "https://github.com/mojombo"))
//        view.addSubview(v)
//        v.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
//        v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupView() {
        title = "Github Users"
        view.addSubview(userListTbl)
        
        NSLayoutConstraint.activate([
            userListTbl.topAnchor.constraint(equalTo: view.topAnchor),
            userListTbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userListTbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userListTbl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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

extension UserListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListItemCell.reuseIdentifier, for: indexPath) as? UserListItemCell else { return UITableViewCell() }
        let a = users[indexPath.row]
        let b = UserInfoViewModel(name: a.nameLogin,
                                  avatar: a.avatarUrl,
                                  url: a.htmlUrl)
        cell.configure(with: b)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let a = users[indexPath.row]
        print("name====\(a.nameLogin)")
    }
    
    
}

