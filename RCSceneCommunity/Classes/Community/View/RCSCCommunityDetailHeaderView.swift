//
//  RCSceneCommunityParallaxHeader.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/7.
//

import UIKit

typealias RCSCChannelListTableHeaderAction = () -> Void

class RCSCCommunityDetailHeaderView: UIView {
    
    var imageUrl: String? {
        willSet {
            if let url = newValue {
                imageView.setImage(with: url)
            } else {
                imageView.image = Asset.Images.bigIcon.image
            }
        }
    }
    
    var image: UIImage? {
        willSet {
            if let image = newValue {
                imageView.image = image
            }
        }
    }
    
    var groupName: String? {
        willSet {
            if let name = newValue {
                self.groupNameLabel.text = name
            }
        }
    }
    
    var subName: String? {
        willSet {
            if let name = newValue {
                self.subNameLabel.text = name
            }
        }
    }
    
    var moreButtonIsHidden: Bool = false {
        didSet {
            moreButton.isHidden = moreButtonIsHidden
        }
    }
    
    var progress: CGFloat = 0 {
        willSet {
            if newValue >= 1 {
                imageView.transform = CGAffineTransform(scaleX: 1.1*newValue, y: 1.1*newValue)
                blur.transform = CGAffineTransform(scaleX: 1.1*newValue, y: 1.1*newValue)
            } else {
                blur.alpha = 1 - newValue
            }
        }
    }
    
    var status: RCSCCommunityUserStatus = .joined {
        didSet {
            if status == .joined {
                moreButton.setTitle("", for: .normal)
                moreButton.backgroundColor = .clear
                moreButton.setImage(Asset.Images.moreIcon.image, for: .normal)
                moreButton.snp.remakeConstraints { make in
                    make.centerY.equalTo(groupNameLabel)
                    make.size.equalTo(CGSize(width: 54, height: 44))
                    make.trailing.equalToSuperview().offset(-6)
                }
            } else {
                moreButton.setTitle("移除", for: .normal)
                moreButton.backgroundColor = .black.alpha(0.5)
                moreButton.setImage(nil, for: .normal)
                moreButton.snp.remakeConstraints { make in
                    make.centerY.equalTo(groupNameLabel)
                    make.size.equalTo(CGSize(width: 54, height: 32))
                    make.trailing.equalToSuperview().offset(-6)
                }
            }
        }
    }
    
    var communityId: String?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Asset.Colors.blue0099FF.color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    private lazy var blur: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.alpha = 0
        return blur
    }()
    
    private lazy var groupNameLabel: UILabel = {
        let groupNameLabel = UILabel()
        groupNameLabel.textAlignment = .left
        groupNameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        groupNameLabel.textColor = .white
        return groupNameLabel
    }()
    
    private lazy var subNameLabel: UILabel = {
        let subNameLabel = UILabel()
        subNameLabel.textAlignment = .left
        subNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        subNameLabel.textColor = Asset.Colors.green74E971.color
        subNameLabel.isHidden = true
        return subNameLabel
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.moreIcon.image, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.isHidden = true
        return button
    }()
    
    var action: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(editImage(notification:)), name: RCSCCommunityEditInfoImageNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        addSubview(blur)
        blur.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        addSubview(groupNameLabel)
        groupNameLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(7)
            make.leading.equalTo(self).offset(15)
        }
        
        addSubview(subNameLabel)
        subNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.groupNameLabel)
            make.top.equalTo(self.groupNameLabel.snp.bottom).offset(2)
        }
        
        addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(groupNameLabel)
            make.size.equalTo(CGSize(width: 54, height: 44))
            make.trailing.equalToSuperview().offset(-6)
        }
    }
    
    @objc private func moreButtonClick() {
        if let action = action {
            action()
        }
    }
    
    @objc private func editImage(notification: Notification) {
        guard let communityId = communityId,
              let _communityId = notification.userInfo?[RCSCCommunityEditInfoImageIDKey] as? String,
              communityId == _communityId,
              let type = notification.userInfo?[RCSCCommunityEditInfoImageTypeKey] as? Int,
              type == 1,
              let url = notification.userInfo?[RCSCCommunityEditInfoImageURLKey] as? String,
              url.count > 0
        else {
            return
        }

        imageView.setImage(with: url, placeholder: nil)
    }
}
