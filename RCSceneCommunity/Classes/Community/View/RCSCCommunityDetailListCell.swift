//
//  RCSceneCommunityChannelListCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/7.
//

import UIKit

enum RCSCChannelType: Int {
    case text
    case voice
    case post
}

extension RCSCChannelType {
    var image: UIImage {
        switch self {
        case .text:
            return Asset.Images.channelHashtagIcon.image
        case .voice:
            return Asset.Images.channelSpeakerIcon.image
        case .post:
            return Asset.Images.channelDailyIcon.image
        }
    }
}

class RCSCCommunityDetailListCell: UITableViewCell {

    var name: String? {
        willSet {
            if let name = newValue {
                nameLabel.text = name
            }
        }
    }
    
    var unReadNumber: Int32 = 0 {
        willSet {
            unReadNumberLabel.isHidden = newValue == 0
            unReadNumberLabel.text = String(newValue)
        }
    }
    
    class var reuseIdentifier: String {
        get {
            return String(describing: RCSCCommunityDetailListCell.self)
        }
    }
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 8
        return container
    }()
    
    private lazy var iconView: UIImageView = {
        let icon = UIImageView()
        icon.image = type.image.resize(CGSize(width: 25, height: 25))
        return icon
    }()
    
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    lazy var unReadNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = Asset.Colors.grayDBDBDB.color
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.isHidden = true
        return label
    }()
    
    var type: RCSCChannelType = .text
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = Asset.Colors.grayF6F6F6.color
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func buildSubViews() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
        }
        
        containerView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 25, height: 25))
            make.centerY.equalToSuperview()
        }
        
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-34)
            make.centerY.equalTo(iconView)
        }
        
        containerView.addSubview(unReadNumberLabel)
        unReadNumberLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.centerY.equalTo(iconView)
            make.trailing.equalToSuperview().offset(-6)
        }
    }
}
