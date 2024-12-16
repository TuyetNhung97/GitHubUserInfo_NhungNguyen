//
//  UserDetailVC.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 15/12/24.
//

import UIKit
import Combine

class UserDetailVC: UIViewController {
    
    // MARK: - Properties
    private var viewModel: UserDetailVM
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: UserDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userCardView: UserCardView = {
        let card = UserCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private lazy var followStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var followerView: FollowView = {
        let view = FollowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: "Followers", icon: "ic_follower")
        return view
    }()
    
    private lazy var followingView: FollowView = {
        let view = FollowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: "Following", icon: "ic_following")
        return view
    }()
    
    private lazy var blogTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "Blog"
        return label
    }()
    
    private lazy var blogDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        fetchUserDetail()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupScrollView()
    }
    
    private func setupNavigationBar() {
        title = "User Details"
        navigationItem.leftBarButtonItem = createBarButtonItem(imageName: "ic_back", action: #selector(handleBackAction))
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        scrollContentView.addSubview(userCardView)
        scrollContentView.addSubview(followStackView)
        scrollContentView.addSubview(blogTitleLabel)
        scrollContentView.addSubview(blogDetailLabel)
        
        followStackView.addArrangedSubview(createSpacerView())
        followStackView.addArrangedSubview(followerView)
        followStackView.addArrangedSubview(followingView)
        followStackView.addArrangedSubview(createSpacerView())
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            userCardView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 16),
            userCardView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            userCardView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            
            followStackView.topAnchor.constraint(equalTo: userCardView.bottomAnchor, constant: 16),
            followStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            followStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            
            blogTitleLabel.topAnchor.constraint(equalTo: followStackView.bottomAnchor, constant: 16),
            blogTitleLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            blogTitleLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            
            blogDetailLabel.topAnchor.constraint(equalTo: blogTitleLabel.bottomAnchor, constant: 8),
            blogDetailLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            blogDetailLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            blogDetailLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollContentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createSpacerView() -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return spacer
    }
    
    private func createBarButtonItem(imageName: String, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.userDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userDetail in
                guard let userDetail else { return }
                self?.configureView(with: userDetail)
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func fetchUserDetail() {
        viewModel.fetchUserDetail()
    }
    
    // MARK: - Configuration
    private func configureView(with user: UserDetailViewModel) {
        userCardView.configure(with: user.userGeneralInfo)
        followerView.setFollowNumber(numberString: user.followerNumber.getFormattedString())
        followingView.setFollowNumber(numberString: user.followingNumber.getFormattedString())
        blogDetailLabel.text = user.blogUrl.isEmpty ? "No Blog URL" : user.blogUrl
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.actionRetryFetchUserDetail()
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func handleBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func actionRetryFetchUserDetail() {
        viewModel.fetchUserDetail()
    }
}


struct UserDetailViewModel {
    var userGeneralInfo: UserInfoViewModel
    var followerNumber: FollowType
    var followingNumber: FollowType
    var blogUrl: String
}
