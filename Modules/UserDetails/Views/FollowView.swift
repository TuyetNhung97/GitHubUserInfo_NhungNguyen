//
//  FollowView.swift
//  GitHubUserInfo_NhungNguyen
//
//  Created by Nguyen Jenny on 15/12/24.
//

import UIKit

class FollowView: UIView {
    
    // MARK: - Subviews
    private lazy var iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 32 // Half of 64 (width/height)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func setupView() {
        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(numberLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            iconBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 64),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 64),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            numberLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: 8),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(title: String, icon: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(named: icon)
    }
    
    func setFollowNumber(numberString: String) {
        numberLabel.text = numberString
    }
}
