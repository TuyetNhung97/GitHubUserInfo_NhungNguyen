//
//  UserListVC.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import UIKit
import Combine

class UserListVC: UIViewController {
    
    // MARK: - Properties
    private var viewModel: UserListVM
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        tableView.register(UserListItemCell.self, forCellReuseIdentifier: UserListItemCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initializer
    init(viewModel: UserListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        loadInitialData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "GitHub Users"
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
                self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        loadingIndicator.startAnimating()
        Task {
            await viewModel.loadUsersFromCoreData()
        }
    }
    
    // MARK: - Actions
    @objc private func pullToRefresh() {
        viewModel.refreshUserList()
    }
    
    private func pushToUserDetail(loginName: String) {
        let userDetailVM = UserDetailVMImpl(
            userService: UserSeviceIml(
                apiService: NetworkServiceImpl()
            ),
            loginUsername: loginName
        )
        let detailVC = UserDetailVC(viewModel: userDetailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func actionRetryFetchUserList() {
        viewModel.fetchUserList()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.actionRetryFetchUserList()
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension UserListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListItemCell.reuseIdentifier, for: indexPath) as? UserListItemCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.users.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.users.value[indexPath.row]
        pushToUserDetail(loginName: selectedUser.name)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.frame.height - 100
        
        if offsetY > threshold, !viewModel.users.value.isEmpty {
            viewModel.fetchUserList()
        }
    }
}
