//
//  UserListVC.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import UIKit
import Combine

class UserListVC: UIViewController {
    
    private var userVM: UserListVM!
    private var cancellables = Set<AnyCancellable>()
    
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
        setupVM()
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
    
    func setupVM() {
        self.userVM = UserListVMImpl(userService: UserSeviceIml(apiService: NetworkServiceImpl()),
                                     coreDataHelper: CoreDataHelperImpl(container: .createUserEntityContainer()))
        self.userVM.users
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.userListTbl.reloadData()
            }
            .store(in: &cancellables)
        Task {
            await self.userVM.loadUsersFromCoreData()
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

extension UserListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userVM.users.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListItemCell.reuseIdentifier, for: indexPath) as? UserListItemCell else { return UITableViewCell() }
        cell.configure(with: userVM.users.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let a = userVM.users.value[indexPath.row]
        print("name====\(a.name)")
    }
    
    
}

