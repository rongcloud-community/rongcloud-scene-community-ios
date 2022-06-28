//
//  RCSCConversationViewController.swift
//  Kingfisher
//
//  Created by shaoshuai on 2022/3/9.
//

import UIKit
import RongIMLib
import MJRefresh
import SVProgressHUD
import SwiftUI

class RCSCConversationViewController: UIViewController {
    
    lazy var header: MJRefreshNormalHeader = {
        let header = MJRefreshNormalHeader()
        header.isHidden = false
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        return header
    }()
    
    private lazy var scrollToBottomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.messageScorllToBottom.image, for: .normal)
        button.addTarget(self, action: #selector(collectionViewScrollToBotton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc private func refresh() {
        refreshConversationMessage()
    }
    
    lazy var  footer: MJRefreshAutoNormalFooter = {
        let footer = MJRefreshAutoNormalFooter()
        footer.isHidden = true
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadMore))
        return footer
    }()
    
    @objc private func loadMore() {
        loadMoreConversation()
    }
    
    var refreshEnable = true {
        didSet {
            header.isHidden = !refreshEnable
        }
    }
    
    var loadMoreEnable = false {
        didSet {
            footer.isHidden = !loadMoreEnable
        }
    }
    
    lazy var emptyView: RCSCConversationEmptyView = {
        let emptyView = RCSCConversationEmptyView()
        emptyView.isHidden = true
        return emptyView
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: RCSceneMessageLayout()
        )
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .white
        view.backgroundView = emptyView
        view.keyboardDismissMode = .onDrag
        view.register(RCSCMessageTextCell.self, forCellWithReuseIdentifier: String(describing: RCSCMessageTextCell.self))
        view.mj_header = header
        view.mj_footer = footer
        
        return view
    }()
    
    lazy var quoteView: RCSCMessageOperationInputBar = {
        let view = RCSCMessageOperationInputBar()
        view.dismiss = { [weak self] in
            self?.modifyMessageFinished()
        }
        view.isHidden = true
        return view
    }()
    
    lazy var blackMask: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .black.alpha(0.2)
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(modifyMessageFinished))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var userStatusBottomBar: RCSCUserStatusBottomBar = {
        let bar = RCSCUserStatusBottomBar(status: userStatus)
        bar.join = {[weak self] in
            guard let self = self else { return }
            RCSCCommunityService.service.joinCommunity(communityId: self.communityId)
        }
        return bar
    }()
    
    lazy var unreadBar: RCSCUnreadBar = {
        let bar = RCSCUnreadBar()
        bar.tapCompletion = { [weak self] in
            guard let self = self else { return }
            guard let firstUnreadMessage = self.firstUnreadMessage else {
                SVProgressHUD.showError(withStatus: "离线未读消息暂不支持跳转")
                self.clearUnreadStatus()
                return
            }
            if self.scrollToMessage(messageUid: firstUnreadMessage.messageUId) {
                self.clearUnreadStatus()
            } else {
                self.fetchUnreadMessages()
            }
        }
        return bar
    }()
    
    
    lazy var muteBar: RCSCMuteStatusBar = RCSCMuteStatusBar()
    
    lazy var typingStatusBar = RCSCTypingStatusBar()
    
    var pushContent: RCSCPushContent?
    
    var popViewControllerCompletion:(()->Void)?
    
    var jumpMessage: RCMessage?
    
    var needScrollToTop = false

    lazy var tmpInputView = RCSCTmpInputView()
    
    var messages = [RCMessage]()
    
    var communityId: String {
        get {
            return communityDetail.uid
        }
    }
    
    var userStatus: RCSCCommunityUserStatus {
        get {
            return communityDetail.communityUser.auditStatus
        }
    }
    
    var conversation: RCConversation? {
        get {
            return RCSCConversationMessageManager.getConversation(communityId: communityId, channelId: channelId)
        }
    }
    
    var isCreator: Bool {
        get {
            return communityDetail.creator == RCSCUser.user?.userId
        }
    }
    
    var firstUnreadMessage: RCMessage?
    
    let channelId: String
    
    var communityDetail: RCSCCommunityDetailData
    
    init(communityDetail: RCSCCommunityDetailData, channelId: String) {
        self.communityDetail = communityDetail
        self.channelId = channelId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        RCSCMarkMessageHub.setConversationInfo(communityId: nil, channelId: nil, viewController: nil)
        clearUnreadStatus()
        if let popViewControllerCompletion = popViewControllerCompletion {
            popViewControllerCompletion()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "消息"
        
        view.backgroundColor = .white
        
        RCSCCommunityManager.manager.currentConversationViewController = self
        
        buildSubViews()
        
        RCSCConversationMessageManager.setDelegate(delegate: self)
        
        registerListener()
        
        registerNotification()
        
        fetchInitializeMessages()
        
        configPushContent()
        
        fetchUnreadCount()
        
        RCSCMarkMessageHub.setConversationInfo(communityId: communityId, channelId: channelId, viewController: self)
    }
    
    func registerListener() {
        RCSCCommunityService.service.registerListener(listener: self)
    }

    private func buildSubViews() {
        
        let barItem = UIBarButtonItem(image: Asset.Images.messageConversationMore.image, style: .plain, target: self, action: #selector(pushChannelInfoEditViewController))
        navigationItem.rightBarButtonItem = barItem
        
        tmpInputView.delegate = self
        view.addSubview(tmpInputView)
        tmpInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).priority(750)
            make.bottom.lessThanOrEqualToSuperview().priority(1000)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(tmpInputView.snp.top)
        }
       
        
        view.addSubview(quoteView)
        quoteView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.tmpInputView)
            make.bottom.equalTo(self.tmpInputView.snp.top)
            make.height.equalTo(RCSCMessageOperationInputBar.height)
        }
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
        collectionView.addGestureRecognizer(gesture)
        
        view.addSubview(blackMask)
        blackMask.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(quoteView.snp.top)
        }
        
        view.addSubview(userStatusBottomBar)
        userStatusBottomBar.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(93)
        }
        
        view.addSubview(unreadBar)
        unreadBar.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(90)
            make.size.equalTo(CGSize(width: 126, height: 36))
        }
        
        view.addSubview(typingStatusBar)
        typingStatusBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
        
        view.addSubview(scrollToBottomButton)
        scrollToBottomButton.snp.makeConstraints { make in
            make.bottom.equalTo(tmpInputView.snp.top).offset(-20)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.trailing.equalToSuperview().offset(-20)
        }
        
        view.addSubview(muteBar)
        muteBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(92)
        }
        if userStatus != .joined {
            tmpInputView.isHidden = true
            userStatusBottomBar.isHidden = false
        } else {
            tmpInputView.isHidden = false
            userStatusBottomBar.isHidden = true
            if communityDetail.communityUser.shutUp == 1 {
                tmpInputView.isHidden = true
                muteBar.isHidden = false
            }
        }
        
        RCSCMarkMessageHub.addMarkMessageView(communityId: communityId, channelId: channelId)
        
        
    }
    
    private func registerNotification() {
        let name = UIApplication.keyboardWillChangeFrameNotification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidUpdate(_:)), name: name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conversationReceiveCommunitySystemMessage(notification:)), name: RCSCCommunityReceiveSystemMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markMessageHubRemoved), name: RCSCMarkMessageHubViewRemovedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markMessageHubAdd), name: RCSCMarkMessageHubViewAddNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(communityDetailChanged(notification:)), name: RCSCCommunityDetailChangedNotification,object: nil)
    }
    
    private func fetchInitializeMessages() {
        fetchNormalMessageInitializeMessages()
    }
    
    private func configPushContent() {
        guard let user = RCSCUser.user else { return }
        RCSCUserInfoCacheManager.getUserInfo(with: communityId, userId: user.userId) { [weak self] info in
            guard let self = self else { return }
            var nickName = user.userName
            if let info = info {
                nickName = info.nickName
            }
            let pushContent = RCSCPushContent(communityName: self.communityDetail.name, channelName: self.communityDetail.channelName(channelId: self.channelId), senderName: nickName, content: nil)
            self.pushContent = pushContent
        }
    }
    
    @objc private func longPressHandler(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, userStatus == .joined else { return }
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        let message = messages[indexPath.row]
        conversationLongPressHandler(message)
    }
    
    @objc private func keyboardDidUpdate(_ notification: Notification) {
        guard let info = notification.userInfo else {
            return
        }
        
        let frameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let frameEndValue = info[frameEndKey] as? NSValue else {
            return
        }
        
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let durationValue = info[durationKey] as? NSNumber
        let duration = durationValue?.doubleValue ?? 0.2
        
        let frameEnd = frameEndValue.cgRectValue
        let offsetY = kScreenHeight - frameEnd.minY
        tmpInputView.snp.updateConstraints { make in
            make.bottom.lessThanOrEqualToSuperview().offset(-offsetY).priority(1000)
        }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func modifyMessageFinished() {
        let _ = self.tmpInputView.resignFirstResponder()
        self.blackMask.isHidden = true
        self.quoteView.isHidden = true
    }
    
    func conversationLongPressHandler(_ message: RCMessage) {
        guard let messageProtocol = message.content as? RCSCMessageProtocol,
              let user = RCSCUser.user,
              var operations = messageProtocol.supportOperations(owner: message.senderUserId == user.userId),
              !operations.isEmpty
        else {
            return SVProgressHUD.showError(withStatus: "该消息暂不支持操作")
        }
                
        if communityDetail.creator == user.userId {
            if !(messageProtocol is RCSCChannelNoticeMessage) {
                RCSCMarkMessageDetailApi(messageUid: message.messageUId).fetch().success { object in
                    DispatchQueue.main.async {
                        operations.append(.deleMark)
                        if !operations.contains(.delete) {
                            operations.append(.delete)
                        }
                        self.showOperationViewController(operations: operations, message: message)
                    }
                }.failed { error in
                    DispatchQueue.main.async {
                        operations.append(.mark)
                        if !operations.contains(.delete) {
                            operations.append(.delete)
                        }
                        self.showOperationViewController(operations: operations, message: message)
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: "该消息暂不支持操作")
            }
        } else {
            showOperationViewController(operations: operations, message: message)
        }
    }
    
    private func showOperationViewController(operations: Array<RCSCMessageOperation>, message: RCMessage) {
        
        if operations.isEmpty {
            return SVProgressHUD.showError(withStatus: "该消息暂不支持操作")
        }
        
        let controller = RCSCMessageOperationViewController(operations: operations) { [weak self] opt in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                self.handleOperation(with: opt, message: message)
            }
        }
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
    
    func jumpToMessage(messageUid: String) {
        
        var find = scrollToMessage(messageUid: messageUid)
        
        if !find {
            guard let message = RCSCConversationMessageManager.getMessageByUid(messageUid: messageUid) else {
                SVProgressHUD.showError(withStatus: "未查找到被标注的消息")
                return
            }
            jumpMessage = message
            SVProgressHUD.show()
            messages.removeAll()
            footer.isHidden = false
            MsgMgr.fetchHistoryMessage(communityId: communityId, channelId: channelId, sendTime: message.sentTime, strategy: .after, fix: true)
        }
    }
    
    func scrollToMessage(messageUid: String) -> Bool {
        var find = false
        for index in 0..<messages.count {
            let message = messages[index]
            if message.messageUId == messageUid {
                find = true
                jumpMessage = message
                let indexPath = IndexPath(row: index, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    for cell in self.collectionView.visibleCells {
                        if let cell = cell as? RCSCMessageBaseCell {
                            if cell.message?.messageUId == self.jumpMessage?.messageUId {
                                cell.blink(setColor: Asset.Colors.blue0099FF.color, repeatCount: 2, duration: 1)
                                break
                            }
                        }
                    }
                }
                break
            }
        }
        return find
    }
    
    @objc private func pushChannelInfoEditViewController() {
        let channelDetail = RCSCChannelDetailViewController(communityId: communityId, channelId: channelId)
        channelDetail.isCreator = isCreator
        self.navigationController?.pushViewController(channelDetail, animated: true)
    }
    
    func clearUnreadStatus() {
        firstUnreadMessage = nil
        if let conversation = conversation, RCSCConversationMessageManager.clearUnreadCount(communityId: communityId, channelId: channelId, time: conversation.sentTime) {
            RCSCConversationMessageManager.syncCommunityReadStatus(communityId: communityId, channelId: channelId, time: conversation.sentTime)
        }
        unreadBar.unreadCount = 0
    }
    
    func fetchUnreadCount() {
        guard let conversation = conversation else {
            return unreadBar.unreadCount = 0
        }
        
        unreadBar.unreadCount = conversation.unreadMessageCount
    }
        
    @objc private func conversationReceiveCommunitySystemMessage(notification: Notification) {
        if let type = notification.object as? RCSCSystemMessageType {
            switch type {
            case .reject:
                communityDetail.communityUser.auditStatus = .reject
                userStatusBottomBar.changeToRejectStatus()
            default:
                break
            }
        }
    }
    
    func typeStatusBarRemakeConstraints(top: CGFloat) {
        typingStatusBar.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
    }
    @objc private func markMessageHubRemoved() {
        typeStatusBarRemakeConstraints(top: 0)
    }
    
    @objc private func markMessageHubAdd() {
        typeStatusBarRemakeConstraints(top: RCSCMarkMessageHubView.RCSCMarkMessageContentHeight)
    }
    
    @objc private func communityDetailChanged(notification: Notification) {
        guard let communityId = notification.object as? String,
              let userInfo = notification.userInfo as? Dictionary<String, Any>,
              let channels = userInfo[RCSCDeleteChannelsKey] as? Array<String>,
              channels.count > 0
        else { return }
        if channels.contains(channelId) {
            let message = userInfo[RCSCCommunityChangedMessageKey] as? String ?? "频道已删除"
            SVProgressHUD.showInfo(withStatus: message)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func collectionViewScrollToBotton() {
        collectionView.scrollToItem(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
}

extension RCSCConversationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emptyView.isHidden = messages.count != 0
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        guard let content = message.content as? RCSCMessageProtocol else {
            return UICollectionViewCell()
        }
        collectionView.register(content.view(), forCellWithReuseIdentifier: content.identifier())
        let identifier = (messages[indexPath.item].content as! RCSCMessageProtocol).identifier()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RCSCMessageBaseCell
        cell.resendHandler = { [weak self] message, type in
            guard let self = self else { return }
            if self.deleteMeesage(message: message) {
                self.messages.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
                self.resendMessage(message: message, type: type)
            }
        }
        cell.contentTapHandler = { [weak self] message, type, sourceView in
            guard let self = self else { return }
            if let markMessage = message.content as? RCSCChannelNoticeMessage {
                let markMessageVC = RCSCMarkMessageViewController(communityId: self.communityId, channelId: self.channelId)
                markMessageVC.isCreator = self.isCreator
                markMessageVC.jumpToMessage = { markMessage in
                    self.jumpToMessage(messageUid: markMessage.messageUid)
                }
                self.navigationController?.pushViewController(markMessageVC, animated: true)
            } else {
                self.browseMedia(with: type, message: message, sourceView: sourceView)
            }
        }
        cell.avatarTapHandler = { [weak self] message in
            guard let self = self else { return }
            if !(message.content is RCSCChannelNoticeMessage) {
                //TODO: 在这里跳转相关的信息从  message 里面拿
                print("uid = \(message.senderUserId) targetId = \(message.targetId)")
              guard  let userId = message.senderUserId,let targetId = message.targetId else{
                  print("error 消息异常")
                  return
              }
                let userIds = [userId]
                SVProgressHUD.show()
                RCSCGetSysUserInfoApi(userIds).fetch().success { [weak self] object in
                    SVProgressHUD.dismiss()
                    guard let self = self else { return  }
                    guard let repo = object else { return }
                    guard repo.count > 0 else { return }
                    let user:RCSCSysMsgUserInfo = repo[0]
                    let portraitUrl :String
                    if let conunt = user.portrait?.count, conunt > 0 {
                        portraitUrl =  user.portrait!
                    }else {
                        portraitUrl = RCSCDefaultAvatar
                    }
                     
                    let userInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: portraitUrl)
                    RCIM.shared().refreshUserInfoCache(userInfo, withUserId: user.userId)
                    let controller = RCSCPrivateMsgChatVC(.ConversationType_PRIVATE, userId: userId)
//                    controller.canCallComing = self.canCallComing
                    self.show(controller, sender: self)
                }.failed { error in
                    SVProgressHUD.dismiss()
                    print("RCSCGetSysUserInfoApi -> \(error)")
                }
            }
        }
        if let jumpMessage = jumpMessage, jumpMessage.messageUId == message.messageUId {
            let cell = cell.updateUI(message)
            cell.contentView.blink(setColor: Asset.Colors.blue0099FF.color, repeatCount: 2, duration: 1)
            self.jumpMessage = nil
            return cell
        }
        return cell.updateUI(message)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == messages.count - 3 {
            scrollToBottomButton.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == messages.count - 3 {
            scrollToBottomButton.isHidden = true
        }
    }
}
