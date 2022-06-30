//
//  RCSCMarkMessageHub.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/9.
//

import UIKit

let RCSCMarkMessageHubViewRemovedNotification = Notification.Name(rawValue: "RCSCMarkMessageHubViewRemovedNotification")
let RCSCMarkMessageHubViewAddNotification = Notification.Name(rawValue: "RCSCMarkMessageHubViewAddNotification")
let RCSCMarkMessageHubViewPushMarkMessageViewControllerNotification = Notification.Name(rawValue: "RCSCMarkMessageHubViewPushMarkMessageViewControllerNotification")

protocol RCSCMarkMessageHubViewDelegate: NSObjectProtocol {
    func removeClick(hubView: RCSCMarkMessageHubView)
}

class RCSCMarkMessageHubView: UIView {
    
    static let RCSCMarkMessageTagID = 999
    
    static let RCSCMarkMessageContentHeight = 41.0
    
    private lazy var iconImageView = UIImageView(image: Asset.Images.messageMarkHubIcon.image)
    
    weak var delegate: RCSCMarkMessageHubViewDelegate?
    
    var messageUid: String?
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = Asset.Colors.black282828.color
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.messageMarkDeleteIcon.image, for: .normal)
        button.addTarget(self, action: #selector(removeFromSuperview), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 22))
        }
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-2)
        }
        
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayE5E8EF.color
        addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tap)
    }
    
    func updateUI(content: RCSCMessageProtocol) {
        contentLabel.text = content.quoteText()
    }
    
    @objc private func remove() {
        guard let delegate = delegate else {
            return
        }
        delegate.removeClick(hubView: self)
    }
    
    @objc private func tap() {
        if let messageUid = messageUid {
            NotificationCenter.default.post(name: RCSCMarkMessageHubViewPushMarkMessageViewControllerNotification, object: messageUid)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        NotificationCenter.default.post(name: RCSCMarkMessageHubViewRemovedNotification, object: nil)
    }
}

func navigationBarHeight() -> CGFloat {
    var statusBarHeight: CGFloat = 0
    if #available(iOS 13, *) {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowsScene = scene as? UIWindowScene else { return 0 }
        guard let statusBarManager = windowsScene.statusBarManager else { return 0 }
        statusBarHeight = statusBarManager.statusBarFrame.height
    } else {
        statusBarHeight = UIApplication.shared.statusBarFrame.height
    }
    return statusBarHeight + 44
}

class RCSCMarkMessageHub: NSObject {
    
    private static let hub = RCSCMarkMessageHub()
    
    private weak var viewController: UIViewController?
    
    private var communityId: String?
    
    private var channelId: String?
    
    private weak var currentHubView: RCSCMarkMessageHubView?
    
    private var currentMarkMessage: RCSCChannelNoticeMessage?
        
    private static let barHeight = navigationBarHeight()
    
    private var markMessageTable = Dictionary<String, Dictionary<String, Array<RCSCChannelNoticeMessage>>>()
    
    private override init() {
        super.init()
        RCSCConversationMessageManager.setDelegate(delegate: self)
    }
    
    private func hubView(content: RCSCMessageProtocol) -> RCSCMarkMessageHubView{
        let hubView = RCSCMarkMessageHubView(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: RCSCMarkMessageHubView.RCSCMarkMessageContentHeight))
        hubView.updateUI(content: content)
        hubView.delegate = self
        hubView.tag = RCSCMarkMessageHubView.RCSCMarkMessageTagID
        return hubView
    }
    
    private func showMarkMessageInViewController(in viewController: UIViewController, content: RCSCChannelNoticeMessage, animation: Bool) {
        guard let markContent = content.content,
              let messageUid = markContent.messageUid,
              let message = RCSCConversationMessageManager.fetchMessageByMessageUid(messageUid: messageUid),
              let messageContent = message.content as? RCSCMessageProtocol
        else { return }
        let hubView = hubView(content: messageContent)
        hubView.messageUid = messageUid
        viewController.view.addSubview(hubView)
        currentHubView = hubView
        if animation {
            UIView.animate(withDuration: 0.5, animations: {
                hubView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 41)
            }, completion: nil)
        } else {
            hubView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 41)
        }
        NotificationCenter.default.post(name: RCSCMarkMessageHubViewAddNotification, object: nil)
    }
    
    private func addMarkMessageView(communityId: String, channelId: String, markMessage: RCSCChannelNoticeMessage?) {
        guard let currentCommunityId = self.communityId,
              let currentChannelId = self.channelId,
              currentCommunityId == communityId,
              currentChannelId == channelId,
              let currentViewController = self.viewController
        else { return }
        if let markMessage = markMessage {
            addMarkMessageViewWithMessage(communityId: communityId, channelId: channelId, markMessage: markMessage)
        } else {
            addMarkMessageViewWithOutMessage(communityId: communityId, channelId: channelId)
        }
    }
    
    private func addMarkMessageViewWithMessage(communityId: String, channelId: String, markMessage: RCSCChannelNoticeMessage) {
        guard let messageUid = markMessage.content?.messageUid,
              let message = RCSCConversationMessageManager.fetchMessageByMessageUid(messageUid: messageUid),
              let messageContent = message.content as? RCSCMessageProtocol,
              let currentViewController = self.viewController
        else { return }
        if currentViewController.view.viewWithTag(RCSCMarkMessageHubView.RCSCMarkMessageTagID) == nil {
            showMarkMessageInViewController(in: currentViewController, content: markMessage, animation: true)
        } else if let currentHubView = currentHubView {
            currentHubView.updateUI(content: messageContent)
        }
        currentMarkMessage = markMessage
    }
    
    private func addMarkMessageViewWithOutMessage(communityId: String, channelId: String) {
        guard let markMessage = markMessageTable[communityId]?[channelId]?.last,
              let messageUid = markMessage.content?.messageUid,
              let message = RCSCConversationMessageManager.fetchMessageByMessageUid(messageUid: messageUid),
              let messageContent = message.content as? RCSCMessageProtocol,
              let currentViewController = self.viewController
        else { return }
        if message.content is RCRecallNotificationMessage, let count = markMessageTable[communityId]?[channelId]?.count {
            markMessageTable[communityId]?[channelId]?.remove(at: count - 1)
            if let count = markMessageTable[communityId]?[channelId]?.count, count > 0 {
                addMarkMessageViewWithOutMessage(communityId: communityId, channelId: channelId)
            }
            return
        }
        showMarkMessageInViewController(in: currentViewController, content: markMessage, animation: false)
        currentMarkMessage = markMessage
    }
    
    private func removeMarkMessageView(communityId: String, channelId: String, markMessage: RCSCChannelNoticeMessage) {
        guard let currentMarkMessage = currentMarkMessage,
              currentMarkMessage.content?.communityUid == markMessage.content?.communityUid,
              currentMarkMessage.content?.channelUid == markMessage.content?.channelUid,
              currentMarkMessage.content?.messageUid == markMessage.content?.messageUid
        else {
            return
        }
        if let currentHubView = currentHubView {
            updateHubView(hubView: currentHubView)
        } else {
            self.currentMarkMessage = nil
        }
    }
    
    //该方法仅处理‘频道通知’收到的标注消息增加的操作
    private func addMarkMessage(markMessage: RCSCChannelNoticeMessage) {
        guard let communityId = markMessage.content?.communityUid,
              let channelId = markMessage.content?.channelUid
        else { return }
        if markMessageTable[communityId] == nil {
            markMessageTable[communityId] = [channelId: [markMessage]]
        } else if markMessageTable[communityId]![channelId] == nil {
            markMessageTable[communityId]![channelId] = [markMessage]
        } else {
            markMessageTable[communityId]![channelId]!.append(markMessage)
        }
        addMarkMessageViewWithMessage(communityId: communityId, channelId: channelId, markMessage: markMessage)
    }
    
    //该方法仅处理‘频道通知’收到的标注消息删除的操作
    private func removeMarkMessage(markMessage: RCSCChannelNoticeMessage) {
        guard let communityId = markMessage.content?.communityUid,
              let channelId = markMessage.content?.channelUid,
              let communityMarkMessages = markMessageTable[communityId],
              var channelMarkMessages = communityMarkMessages[channelId],
              channelMarkMessages.count > 0
        else { return }
        for (index, obj) in channelMarkMessages.enumerated() {
            if markMessage.content?.messageUid == obj.content?.messageUid {
                channelMarkMessages.remove(at: index)
                markMessageTable[communityId]![channelId] = channelMarkMessages
                break
            }
        }
        removeMarkMessageView(communityId: communityId, channelId: channelId, markMessage: markMessage)
    }
    
    private func  updateHubView(hubView: RCSCMarkMessageHubView) {
        guard let currentMarkMessage = self.currentMarkMessage,
              let communityId = currentMarkMessage.content?.communityUid,
              let channelId = currentMarkMessage.content?.channelUid,
              let channels = markMessageTable[communityId],
              var markMessages = channels[channelId]
        else {
            return hubView.removeFromSuperview()
        }
        for (index, obj) in markMessages.enumerated() {
            if currentMarkMessage.content?.messageUid == obj.content?.messageUid {
                markMessages.remove(at: index)
                break
            }
        }
        markMessageTable[communityId]![channelId] = markMessages
        if let nextMarkMessage = markMessages.last,
           let messageUid = nextMarkMessage.content?.messageUid,
           let message = RCSCConversationMessageManager.fetchMessageByMessageUid(messageUid: messageUid),
           let messageContent = message.content as? RCSCMessageProtocol {
            self.currentMarkMessage = nextMarkMessage
            hubView.updateUI(content: messageContent)
        } else {
            hubView.removeFromSuperview()
        }
    }
    
    static func addMarkMessageView(communityId: String, channelId: String) {
        hub.addMarkMessageView(communityId: communityId, channelId: channelId, markMessage: nil)
    }
    
    static func setConversationInfo(communityId: String?, channelId: String?, viewController: UIViewController?) {
        hub.communityId = communityId
        hub.channelId = channelId
        hub.viewController = viewController
        guard let communityId = communityId, let channelId = channelId else { return }
        guard let _ = hub.markMessageTable[communityId]?[channelId] else {
            //第一次进入频道会话页面拉取服务端标注消息
            //此为分页接口。只取前100条数据
            RCSCCommunityMarkMessageListApi(channelUid: channelId, pageNum: 1, pageSize: 100).fetch().success { object in
                guard let object = object else { return }
                var result = Array<RCSCChannelNoticeMessage>()
                //获取数据倒序重排
                for markInfo in object.records.reversed() {
                    var noticeMessage = RCSCChannelNoticeMessage()
                    var noticeMessageContent = RCSCChannelNoticeMessageContent(fromUserId: markInfo.uid, communityUid: communityId, channelUid: markInfo.channelUid, message: nil, messageUid: markInfo.messageUid, type: nil)
                    noticeMessage.content = noticeMessageContent
                    result.append(noticeMessage)
                }
                DispatchQueue.main.async {
                    hub.markMessageTable[communityId] = [channelId:result]
                    if result.count > 0 {
                        self.addMarkMessageView(communityId: communityId, channelId: channelId)
                    }
                }
            }
            return
        }
        self.addMarkMessageView(communityId: communityId, channelId: channelId)
    }
    
    static func receiveMarkMessage(markMessage: RCSCChannelNoticeMessage) {
        guard let type = markMessage.content?.type else { return }
        DispatchQueue.main.async {
            switch type {
            case .mark:
                hub.addMarkMessage(markMessage: markMessage)
            case .deleteMark:
                hub.removeMarkMessage(markMessage: markMessage)
            default:
                break
            }
        }
    }
}

extension RCSCMarkMessageHub: RCSCMarkMessageHubViewDelegate {
    func removeClick(hubView: RCSCMarkMessageHubView) {
        updateHubView(hubView: hubView)
    }
}

extension RCSCMarkMessageHub: RCSCConversationMessageManagerDelegate {
    func onMessageRecall(_ messages: [RCMessage]!) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var deleteCurrent = false
            for message in messages {
                if let currentMarkMessage = self.currentMarkMessage, message.messageUId == currentMarkMessage.content?.messageUid {
                    if let currentHubView = self.currentHubView {
                        self.updateHubView(hubView: currentHubView)
                    }
                }
                self.removeValueFromMarkMessageTable(message: message)
            }
        }
    }
    
    //此处仅处理收到消息撤回包含有被引用的消息的相关操作
    func removeValueFromMarkMessageTable(message: RCMessage) {
        if var markMessages = markMessageTable[message.targetId]?[message.channelId] {
            for (index, value) in markMessages.enumerated() {
                if value.content?.messageUid == message.messageUId {
                    markMessages.remove(at: index)
                    markMessageTable[message.targetId]?[message.channelId] = markMessages
                    break
                }
            }
        }
    }
}
