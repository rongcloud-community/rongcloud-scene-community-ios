//
//  RCSceneGroupListCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/7.
//

let RCSCCommunityBadgeUpdateNotification = Notification.Name(rawValue: "RCSCCommunityBadgeUpdateNotification")
let RCSCCommunityToggleNotification = Notification.Name(rawValue: "RCSCCommunityToggleNotification")

let kRCSCCommunityListSelectedKey = "kRCSCCommunityListSelectedKey"
let kRCSCCommunityListIdKey = "kRCSCCommunityListIdKey"

class RCSCCommunityListCell: UICollectionViewCell {
    
    lazy var selectedView: UIView = {
        let selectedView = UIView()
        selectedView.layer.masksToBounds = true
        selectedView.layer.cornerRadius = 33
        selectedView.layer.borderColor = Asset.Colors.blue0099FF.color.cgColor
        selectedView.layer.borderWidth = 2.8
        return selectedView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Asset.Colors.redF31D8A.color
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 27
        return imageView
    }()
    
    lazy var badgeView: UIView = {
        let badgeView = UIView()
        badgeView.backgroundColor = Asset.Colors.redF31D8A.color
        badgeView.layer.masksToBounds = true
        badgeView.layer.cornerRadius = 8
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 2
        badgeView.isHidden = true
        return badgeView
    }()
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if !isSelected {
                NotificationCenter.default.post(name: RCSCCommunityToggleNotification, object: nil, userInfo: [kRCSCCommunityListSelectedKey: isSelected, kRCSCCommunityListIdKey: communityId ?? ""])
            } else {
                badgeView.isHidden = true
            }
        }
    }
    
    var imageUrl: String? {
        willSet {
            guard let url = newValue else { return }
            imageView.setImage(with: url)
        }
    }
    
    var communityId: String?
    
    var isShowBadge: Bool = false {
        didSet {
            if !isSelected {
                badgeView.isHidden = !isShowBadge
            } else {
                badgeView.isHidden = true
            }

        }
    }
    
    static let reuseIdentifier = String(describing: RCSCCommunityListCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        buildSubViews()
        self.selectedBackgroundView = selectedView
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge(notification:)), name: RCSCCommunityBadgeUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editImage(notification:)), name: RCSCCommunityEditInfoImageNotification, object: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        
        contentView.addSubview(badgeView)
        badgeView.snp.makeConstraints { make in
            make.centerX.equalTo(imageView.snp.trailing).offset(-8)
            make.centerY.equalTo(imageView.snp.top).offset(8)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
    
    @objc private func updateBadge(notification: Notification) {
        guard let communityId = communityId, let _communityId = notification.userInfo?[kRCSCCommunityListIdKey] as? String, communityId == _communityId else {
            return
        }

        if let isShow = notification.object as? Bool, !isSelected {
            badgeView.isHidden = !isShow
        }
    }
    
    @objc private func editImage(notification: Notification) {
        guard let communityId = communityId,
              let _communityId = notification.userInfo?[RCSCCommunityEditInfoImageIDKey] as? String,
              communityId == _communityId,
              let type = notification.userInfo?[RCSCCommunityEditInfoImageTypeKey] as? Int,
              type == 0,
              let url = notification.userInfo?[RCSCCommunityEditInfoImageURLKey] as? String,
              url.count > 0
        else {
            return
        }

        imageView.setImage(with: url, placeholder: nil)
    }
}
