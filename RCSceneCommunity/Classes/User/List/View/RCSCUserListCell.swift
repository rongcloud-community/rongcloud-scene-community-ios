//
//  RCSCUserListCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/11.
//

import UIKit



typealias RCSCUserListCellAction = (() -> Void)

enum RCSCUserListCellType {
    case normal
    case at
}

class RCSCUserListCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: RCSCUserListCell.self)
    
    var type: RCSCUserListCellType = .normal {
        willSet {
            if newValue == .at {
                ownerLabel.isHidden = true
                moreButton.isEnabled = false
                moreButton.setImage(Asset.Images.messageUserArrow.image, for: .normal)
            } else {
                moreButton.isEnabled = true
                moreButton.setImage(Asset.Images.userListMoreIcon.image, for: .normal)
            }
        }
    }
    
    var moreAction: RCSCUserListCellAction?
    
    var hideMoreButton: Bool = false {
        didSet {
            moreButton.isHidden = hideMoreButton
        }
    }
    
    var data: RCSCCommunityUser? = nil {
        didSet {
            guard let data = data else { return }
            avatar.setImage(with: data.portrait, placeholder: Asset.Images.defaultAvatarIcon.image)
            nameLabel.text = data.name
            ownerLabel.isHidden = !data.creatorFlag
        }
    }
    
    private lazy var avatar: UIImageView = {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFill
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 27
        avatar.backgroundColor = Asset.Colors.blue0099FF.color
        return avatar
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.text = "创建者"
        label.backgroundColor = Asset.Colors.blue0099FF.color
        label.textAlignment = .center
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.userListMoreIcon.image, for: .normal)
        button.addTarget(self, action: #selector(moreClick), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 54, height: 54))
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(ownerLabel)
        ownerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 20))
            make.trailing.equalTo(moreButton.snp.leading).offset(-10)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatar.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(ownerLabel.snp.leading).offset(-10)
        }
    }
    
    @objc private func moreClick() {
        if let block = moreAction {
            block()
        }
    }
}
