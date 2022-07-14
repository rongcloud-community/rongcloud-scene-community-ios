//
//  RCSCMessageBaseCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/21.
//

import UIKit

class RCSCMessageBaseCell: UICollectionViewCell, RCSCCellProtocol  {
    lazy var nameLabel = UILabel()
    lazy var timeLabel = UILabel()
    lazy var avatarImageView = UIImageView()
    lazy var sendFailView: RCSCMessageSendFailView = {
        let sendFailView = RCSCMessageSendFailView()
        sendFailView.layer.masksToBounds = true
        sendFailView.layer.cornerRadius = 12.5
        sendFailView.isHidden = true
        return sendFailView
    }()
    
    var nameString: String = "" {
        didSet {
            nameLabel.text = nameString
        }
    }
    
    var avatarString: String = "" {
        didSet {
            avatarImageView.setImage(with: avatarString, placeholder: Asset.Images.defaultAvatarIcon.image)
        }
    }
    
    var type: RCSCMessageType?
    
    var message: RCMessage?
    
    var resendHandler: ((RCMessage, RCSCMessageType) -> Void)?
    
    var avatarTapHandler: ((RCMessage) -> Void)?
    
    var contentTapHandler: ((RCMessage, RCSCMessageType, UIView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.backgroundColor = .blue
        avatarImageView.image = Asset.Images.maleIcon.image
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 27
        avatarImageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTap))
        avatarImageView.addGestureRecognizer(tap)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(18)
            make.width.height.equalTo(54)
        }
        
        nameLabel.text = "--"
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = UIColor(byteRed: 40, green: 40, blue: 40, alpha: 0.5)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.top.equalTo(avatarImageView)
            make.width.lessThanOrEqualTo(120)
            make.height.equalTo(20)
        }
        
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = UIColor(byteRed: 40, green: 40, blue: 40, alpha: 0.2)
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(notification:)), name: RCSCMediaDataUploadProgressNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessageFinished(notification:)), name: RCSCSendMessageCompletionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCommunityName(notification:)), name: RCSCUserInfoCacheUpdateNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @discardableResult
    func updateUI(_ message: RCMessage) -> RCSCCellProtocol {
        self.message = message
        
//        if let content = message.content, let senderUserInfo = content.senderUserInfo {
//            var imageUrl = ""
//            if let userInfo = RCSCUserInfoCacheManager.getUserInfo(with: message.targetId, userId: message.senderUserId ?? content.senderUserInfo.userId) {
//                nameLabel.text = userInfo.nickName
//                imageUrl = userInfo.portrait ?? ""
//            } else {
//                nameLabel.text = senderUserInfo.name ?? ""
//                imageUrl = senderUserInfo.portraitUri ?? ""
//            }
//            avatarImageView.setImage(with: imageUrl, placeholder: Asset.Images.defaultAvatarIcon.image)
//        }
        
        timeLabel.text = message.sentTime.timeString
        
        sendFailView.isHidden = message.sentStatus != .SentStatus_FAILED
        sendFailView.resendHandler = { [weak self] in
            guard let self = self,
                  let block = self.resendHandler,
                  let type = self.type
            else { return }
            block(message, type)
        }
        let expends = message.expansionDic ?? [:]
        expends.forEach { item in
            guard let PluginView = RCSCMessagePlugins[item.key] else { return }
            let view = PluginView.init()
            view.updateUI(item.value)
            addSubview(view)
        }
    
        return self
    }
    
    
    @objc private func updateProgress(notification: Notification) {
        if let (messageId,progress) = notification.object as? (Int,Int32) {
            if let message = message, message.messageId == messageId {
                updateProgress(messageId: messageId, progress: Float(progress))
            }
        }
    }
    
    @objc private func sendMessageFinished(notification: Notification) {
        if let (messageId,code) = notification.object as? (Int,Int) {
            if let message = message, message.messageId == messageId {
                sendMessageFinished(messageId: messageId, code: code)
            }
        }
    }
    
    @objc private func updateCommunityName(notification: Notification) {
        guard let object = notification.object as? RCSCCommunityUserInfo,
              let userInfo = notification.userInfo,
              let communityId = userInfo[kCacheCommunityIdKey] as? String,
              let userId = userInfo[kCacheUserIdKey] as? String,
              let message = message
        else { return }
        if communityId == message.targetId && (message.senderUserId == userId || message.content?.senderUserInfo?.userId == userId) {
            nameLabel.text = object.nickName
            avatarImageView.setImage(with: object.portrait)
        }
    }
    
    @objc private func avatarTap() {
        if let message = message, let avatarTapHandler = avatarTapHandler {
            avatarTapHandler(message)
        }
    }
    
    func updateProgress(messageId: Int, progress: Float) {}
    
    func sendMessageFinished(messageId: Int, code: Int) {}
}
