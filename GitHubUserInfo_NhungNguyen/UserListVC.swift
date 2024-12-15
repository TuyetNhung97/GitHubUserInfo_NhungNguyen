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
    
    
    private lazy var refeshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    
    private lazy var userListTbl: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.contentInset = .init(top: 16, left: 0, bottom: 0, right: 0)
        table.register(UserListItemCell.self, forCellReuseIdentifier: UserListItemCell.reuseIdentifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupVM()
    }
    
    func setupView() {
        view.addSubview(userListTbl)
        userListTbl.refreshControl = refeshControl
        
        NSLayoutConstraint.activate([
            userListTbl.topAnchor.constraint(equalTo: view.topAnchor),
            userListTbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userListTbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userListTbl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func setupNavigationBar() {
        title = "Github Users"
    }
    
    func setupVM() {
        self.userVM = UserListVMImpl(userService: UserSeviceIml(apiService: NetworkServiceImpl()),
                                     coreDataHelper: CoreDataHelperImpl(container: .createUserEntityContainer()))
        self.userVM.users
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.userListTbl.reloadData()
                self.refeshControl.endRefreshing()
            }
            .store(in: &cancellables)
        Task {
            await self.userVM.loadUsersFromCoreData()
        }
    }
    
    func pushToUserDetail(loginName: String) {
        let userDetailVM = UserDetailVMImpl(userService: UserSeviceIml(apiService: NetworkServiceImpl()),
                                            loginUsername: loginName)
        let vc = UserDetailVC(userDetailVM: userDetailVM)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pullToRefresh() {
        self.userVM.refreshUserList()
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
        let dataUser = userVM.users.value[indexPath.row]
        self.pushToUserDetail(loginName: dataUser.name)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Check if we are near the bottom of the table view
        if offsetY > contentHeight - frameHeight - 100 {
            if !userVM.users.value.isEmpty {
                print("load more call")
                userVM.fetchUserList()
            }
            
        }
    }
    
}

