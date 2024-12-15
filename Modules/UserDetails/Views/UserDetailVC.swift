//
//  UserDetailVC.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 15/12/24.
//

import UIKit
import Combine

class UserDetailVC: UIViewController {
    
    private var userDetailVM: UserDetailVM!
    private var cancellables = Set<AnyCancellable>()
    
    init(userDetailVM: UserDetailVM) {
        super.init(nibName: nil, bundle: nil)
        self.userDetailVM = userDetailVM
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private lazy var userDetailScrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var scrollContainerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userDetailCard: UserCardView = {
       let view = UserCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var followStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var followerView: FollowView = {
       let view = FollowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: "Follower", icon: "ic_follower")
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
         return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupVM()
    }
    
    func setupView() {
        setupNavigationBar()
        addSubView()
        
        
        let scrollContentGuide = userDetailScrollView.contentLayoutGuide
        let scrollFrameGuide = userDetailScrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            userDetailScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            userDetailScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userDetailScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userDetailScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollContainerView.topAnchor.constraint(equalTo: scrollContentGuide.topAnchor),
            scrollContainerView.leadingAnchor.constraint(equalTo: scrollContentGuide.leadingAnchor),
            scrollContainerView.trailingAnchor.constraint(equalTo: scrollContentGuide.trailingAnchor),
            scrollContainerView.bottomAnchor.constraint(equalTo: scrollContentGuide.bottomAnchor),
            
            scrollContainerView.leadingAnchor.constraint(equalTo: scrollFrameGuide.leadingAnchor),
            scrollContainerView.trailingAnchor.constraint(equalTo: scrollFrameGuide.trailingAnchor),
                        
            userDetailCard.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: 16),
            userDetailCard.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor),
            userDetailCard.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor),
            
            followStackView.topAnchor.constraint(equalTo: userDetailCard.bottomAnchor, constant: 16),
            followStackView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor),
            followStackView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor),
            followStackView.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor),
            
            blogTitleLabel.topAnchor.constraint(equalTo: followStackView.bottomAnchor, constant: 16),
            blogTitleLabel.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            blogTitleLabel.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
            
            blogDetailLabel.topAnchor.constraint(equalTo: blogTitleLabel.bottomAnchor, constant: 12),
            blogDetailLabel.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            blogDetailLabel.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
            blogDetailLabel.bottomAnchor.constraint(greaterThanOrEqualTo: scrollContainerView.bottomAnchor, constant: -16),
        ])
    }
    
    func setupNavigationBar() {
        title = "User details"
        let icBack = UIImage(named: "ic_back")
        
        let button = UIButton(type: .custom)
        button.setImage(icBack, for: .normal)
        button.frame = CGRect(x: 16.0, y: 0.0, width: 20, height: 20)
        button.addTarget(self, action: #selector(handleActionBack), for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func addSubView() {
        view.backgroundColor = .white
        view.addSubview(userDetailScrollView)
        userDetailScrollView.addSubview(scrollContainerView)
        scrollContainerView.addSubview(userDetailCard)
        scrollContainerView.addSubview(followStackView)
        
        followStackView.addArrangedSubview(createEmptyView())
        followStackView.addArrangedSubview(followerView)
        followStackView.addArrangedSubview(followingView)
        followStackView.addArrangedSubview(createEmptyView())
        
        scrollContainerView.addSubview(blogTitleLabel)
        scrollContainerView.addSubview(blogDetailLabel)
    }
    
    func createEmptyView() -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return spacer
    }
    
    func setupVM() {
        self.userDetailVM.userDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dataUserdetail in
                guard let self = self, let dataUserdetail else { return }
                self.configure(with: dataUserdetail)
            }
            .store(in: &cancellables)
        self.userDetailVM.fetchUserDetail()
    }
    
    func configure(with user: UserDetailViewModel) {
        userDetailCard.configure(with: user.userGeneralInfo)
        followerView.setFollowNumber(numberString: user.followerNumber.getFormattedString())
        followingView.setFollowNumber(numberString: user.followingNumber.getFormattedString())
        blogDetailLabel.text = user.blogUrl
    }
    
    @objc func handleActionBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UserDetailVC: UIScrollViewDelegate {
    
}

struct UserDetailViewModel {
    var userGeneralInfo: UserInfoViewModel
    var followerNumber: FollowType
    var followingNumber: FollowType
    var blogUrl: String
}
