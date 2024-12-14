//
//  UserListItemCell.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 14/12/24.
//

import UIKit

class UserListItemCell: UITableViewCell {
    // MARK: - UI Elements
    private lazy var userCardView: UserCardView = {
       let view = UserCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var userInfo: UserInfoViewModel?
    static var reuseIdentifier = "UserListItemCell"
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NOT USE")
    }
    
    // MARK: - Configure View
    func configure(with user: UserInfoViewModel) {
        userCardView.configure(with: user)
    }
    
    // MARK: - View Setup
    func setupView() {
        contentView.addSubview(userCardView)
        NSLayoutConstraint.activate([
            userCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            userCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            userCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
