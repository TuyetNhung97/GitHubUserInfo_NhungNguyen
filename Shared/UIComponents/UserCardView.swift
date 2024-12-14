//
//  UserCardView.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 13/12/24.
//

import UIKit
import SwiftUI
import Kingfisher

class UserCardView: UIView {
    // MARK: - UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 50
        imgView.clipsToBounds = true
        imgView.backgroundColor = .systemGray5
        return imgView
    }()
    
    private lazy var avatarBackgroundView: UIView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = 16
        imgView.clipsToBounds = true
        imgView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return imgView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.4)
        return view
    }()
    
    private var verticalSV: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .leading
        sv.spacing = 8
        return sv
    }()
    
    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private var locationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var locationImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(named: "ic_location")
        return img
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Properties
    private var userInfo: UserInfoViewModel?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    private func setupView() {
        
        // Add subviews
        addSubview(containerView)
        containerView.addSubview(avatarBackgroundView)
        avatarBackgroundView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(lineView)
        containerView.addSubview(verticalSV)
        verticalSV.addArrangedSubview(urlLabel)
        verticalSV.addArrangedSubview(locationView)
        locationView.addSubview(locationImageView)
        locationView.addSubview(locationLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Constraints containerView
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Constraints avatarBackgroundView
            avatarBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            avatarBackgroundView.widthAnchor.constraint(equalToConstant: 108),
            avatarBackgroundView.heightAnchor.constraint(equalToConstant: 108),
            
            // Constraints avatarImageView
            avatarImageView.centerYAnchor.constraint(equalTo: avatarBackgroundView.centerYAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: avatarBackgroundView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Constraints nameLabel
            nameLabel.topAnchor.constraint(equalTo: avatarBackgroundView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarBackgroundView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Constraints lineView
            lineView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            lineView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Constraints verticalSV
            verticalSV.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 8),
            verticalSV.leadingAnchor.constraint(equalTo: lineView.leadingAnchor),
            verticalSV.trailingAnchor.constraint(equalTo: lineView.trailingAnchor),
            verticalSV.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            // Constraints locationImageView
            locationImageView.topAnchor.constraint(equalTo: locationView.topAnchor),
            locationImageView.leadingAnchor.constraint(equalTo: locationView.leadingAnchor),
            locationImageView.bottomAnchor.constraint(equalTo: locationView.bottomAnchor),
            locationImageView.widthAnchor.constraint(equalToConstant: 24),
            locationImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Constraints locationLabel
            locationLabel.topAnchor.constraint(equalTo: locationImageView.topAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: locationView.trailingAnchor, constant: -16),
            locationLabel.bottomAnchor.constraint(equalTo: locationImageView.bottomAnchor)
        ])
    }
    
    private func formatURL(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([
            .foregroundColor : UIColor.blue,
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ],
                                       range: NSRange(location: 0, length: text.count))
        
        return attributedString
    }
    
    @objc func handleLinkTap() {
        guard let urlString = userInfo?.url else { return }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Configure View
    func configure(with user: UserInfoViewModel) {
        self.userInfo = user
        avatarImageView.isHidden = user.avatar.isEmpty
        avatarImageView.kf.setImage(with: URL(string: user.avatar))
        nameLabel.text = user.name
        locationLabel.isHidden = user.location.isEmpty
        locationLabel.text = user.location
        locationImageView.isHidden = user.location.isEmpty
        urlLabel.isHidden = user.url.isEmpty
        urlLabel.attributedText = formatURL(text: user.url)
        
    }
}

struct UserInfoViewModel {
    var name: String
    var avatar: String
    var location: String = ""
    var url: String
}

struct UserCardViewPreview: UIViewRepresentable {
    let user: UserInfoViewModel
    
    // This method creates and returns your UserCardView
    func makeUIView(context: Context) -> UserCardView {
        let userCardView = UserCardView()
        userCardView.configure(with: user)
        return userCardView
    }
    
    func updateUIView(_ uiView: UserCardView, context: Context) {
        // Updates can be handled here (if needed)
    }
}

struct UserCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrapping the UserCardViewPreview with the sample user
        UserCardViewPreview(user: UserInfoViewModel(name: "Nhung",
                                                    avatar: "https://avatars.githubusercontent.com/u/1?v=4",
                                                    location: "Việt Nam",
                                                    url: "https://avatars.githubusercontent.com/u/1?v=4"))
        .frame(height: 140)
        .padding(16)
        .background(Color.black)
    }
}
