//
//  RCSCMessageChannelNoticeCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/9.
//

import UIKit
import RongCloudOpenSource

extension RCSCChannelNoticeMessageType {
    func text(name: String) -> String {
        switch self {
        case .join:
            return "\(name) 加入了社区"
        case .mark:
            return "\(name) 标注了一条消息"
        case .mute:
            return "\(name) 被禁言"
        case .releaseMute:
            return "\(name) 解除禁言"
        case .deleteMark:
            return "\(name) 删除了一条标注消息"
        }
    }
}
class RCSCMessageChannelNoticeCell: RCSCMessageBaseCell {
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = Asset.Colors.black282828.color
        return label
    }()
    
    private lazy var contentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        button.setTitleColor(Asset.Colors.blue0099FF.color, for: .normal)
        button.setTitle("点击查看", for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .channelNotice
        avatarImageView.contentMode = .scaleAspectFit
        nameLabel.text = "系统消息"
        avatarImageView.backgroundColor = Asset.Colors.blue0099FF.color
        avatarImageView.image = Asset.Images.messageSystemAvatar.image
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(contentButton)
        contentButton.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 74, height: 30))
        }
    }
    
    @objc private func buttonClick() {
        if let handler = contentTapHandler, let message = message {
            handler(message, type!, self)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
       
        let width = layoutAttributes.frame.width
        let size = contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        layoutAttributes.frame.size = CGSize(width: size.width, height: 120)
        return layoutAttributes
    }
    
    override func updateUI(_ message: RCMessage) -> RCSCCellProtocol {
        super.updateUI(message)
        guard
            let content = message.content as? RCSCChannelNoticeMessage,
            let userId = content.content?.fromUserId,
            let type = content.content?.type,
            let message = content.content?.message
        else { return self }
        contentLabel.text = message
        contentButton.isHidden = type != .mark
        return self
    }
}
