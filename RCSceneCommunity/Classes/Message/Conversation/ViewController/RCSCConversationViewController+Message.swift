//
//  RCSCConversationViewController+Message.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/13.
//

import Foundation
import Photos
import SVProgressHUD

extension RCSCMessageOperation {
    func isValid(_ message: RCMessage) -> Bool {
        switch self {
        case .edit, .copy:
            return message.content is RCTextMessage || message.content is RCReferenceMessage
        case .quote, .delete, .deleMark:
            return true
        case .mark:
            return !(message.content is RCSCChannelNoticeMessage)
        default:
            return false
        }
    }
}

extension RCSCConversationViewController {
    
    func fetchNormalMessageInitializeMessages() {
        
        //获取第一条未读消息，因为在获取历史消息后有相关的未读状态clear操作，所以放在拉去历史消息钱获取
        firstUnreadMessage = RCSCConversationMessageManager.fetchFirstUnreadMessage(communityId: communityId, channelId: channelId)
        
        MsgMgr.fetchConversationInitializedHistoryMessage(communityId: communityId, channelId: channelId, conversation: conversation)
    }
    
    func fetchUnreadMessages() {
        needScrollToTop = true
        loadMoreEnable = true
        messages.removeAll()
        collectionView.reloadData()
        if let firstUnreadMessage = firstUnreadMessage {
            MsgMgr.fetchHistoryMessage(communityId: communityId, channelId: channelId, sendTime: firstUnreadMessage.sentTime - 1, strategy: .after)
        }
    }
    
    func refreshConversationMessage() {
        if let message = messages.first, refreshEnable {
            MsgMgr.fetchHistoryMessage(communityId: communityId, channelId: channelId, sendTime: message.sentTime, strategy: .before)
        } else {
            header.endRefreshing()
            SVProgressHUD.showInfo(withStatus: "无数据")
        }
    }
    
    func loadMoreConversation() {
        if let message = messages.last, loadMoreEnable {
            MsgMgr.fetchHistoryMessage(communityId: communityId, channelId: channelId, sendTime: message.sentTime, strategy: .after)
        } else {
            footer.endRefreshing()
            SVProgressHUD.showInfo(withStatus: "无数据")
        }
    }
    
    func add(_ message: RCMessage) {
        messages.append(message)
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    private func reloadItems(messages: Array<RCMessage>, recall: Bool = false) {
        var indexPaths = Array<IndexPath>()
        for message in messages {
            for (index,value) in self.messages.enumerated() {
                if recall {
                    if (value.messageId == message.messageId) {
                        reloadRecallMessageContainedInReferenceMessage(messageUID: value.messageUId ?? "",
                                                                       indexPaths: &indexPaths)
                        self.messages[index] = message
                        indexPaths.append(IndexPath(row: index, section: 0))
                        break
                    }
                } else {
                    if (value.messageUId == message.messageUId) {
                        self.messages[index] = message
                        indexPaths.append(IndexPath(row: index, section: 0))
                        break
                    }
                }
            }
        }
        self.collectionView.reloadItems(at: indexPaths)
    }
    
    private func reloadRecallMessageContainedInReferenceMessage(messageUID: String, indexPaths: inout Array<IndexPath>) {
        for (index,value) in messages.enumerated() {
            if let referenceMsg = value.content as? RCReferenceMessage,
               referenceMsg.referMsgUid == messageUID {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
        }
    }
    
    func handleOperation(with opt: RCSCMessageOperation, message: RCMessage) {
        guard let content = message.content as? RCSCMessageProtocol,
              opt.isValid(message)
        else {
            SVProgressHUD.showError(withStatus: "当前消息不支该操作")
            return
        }
        switch opt {
        case .edit:
            if let user = RCSCUser.user, user.userId != message.senderUserId {
                return SVProgressHUD.showError(withStatus: "只能编辑自己发送的消息")
            }
            self.quoteView.isHidden = false
            self.quoteView.text = content.quoteText()
            self.tmpInputView.operation = (opt:opt, msg: message)
            self.blackMask.isHidden = false
        case .quote:
            self.quoteView.isHidden = false
            self.quoteView.text = content.quoteText()
            self.tmpInputView.operation = (opt:opt, msg: message)
            self.blackMask.isHidden = false
        case .copy:
            if let textContent = content as? RCTextMessage {
                SVProgressHUD.showSuccess(withStatus: "已经复制到剪贴板")
                UIPasteboard.general.string = textContent.content
            }
        case .delete:
            if let user = RCSCUser.user, user.userId != message.senderUserId && user.userId != communityDetail.creator {
                return SVProgressHUD.showError(withStatus: "只能撤回自己发送的消息")
            }
            let index = messages.firstIndex { msg in
                return msg.messageUId == message.messageUId
            }
            if message.sentStatus == .SentStatus_SENDING {
                return SVProgressHUD.showError(withStatus: "消息发送中，禁止撤回")
            }
            guard let index = index else { return }
            let message = self.messages[index]
            
            RCSCConversationMessageManager.recallMessage(message: message)
        case .mark:
            RCSCCommunityService.service.markMessage(channelId: channelId, messageUid: message.messageUId ?? "")
            
        case .deleMark:
            if message.messageUId != nil {
                RCSCCommunityDeleteMarkApi(messageUid: message.messageUId ?? "").deleteMark().success { _ in
                    debugPrint("标注消息删除成功")
                }.failed { error in
                    SVProgressHUD.showError(withStatus: "标注消息删除失败")
                }
            } else {
                SVProgressHUD.showError(withStatus: "标注消息删除失败")
            }
        default:
            return
        }
    }
    
    private func toggleMuteUI() {
        RCSCCommunityDetailApi(communityId: communityId).fetch().success {[weak self] object in
            guard let self = self, let obj = object else { return }
            DispatchQueue.main.async {
                self.communityDetail.communityUser.shutUp = obj.communityUser.shutUp
                self.muteBar.isHidden = obj.communityUser.shutUp == 0
                self.tmpInputView.isHidden = !self.muteBar.isHidden
            }
        }
    }
    
    private func handleChannelNoticeMessage(message: RCSCChannelNoticeMessage) {
        guard let type = message.content?.type else { return }
        switch type {
        case .join:
            tmpInputView.isHidden = false
            userStatusBottomBar.isHidden = true
            communityDetail.communityUser.auditStatus = .joined
        case .mute,.releaseMute:
            toggleMuteUI()
        default:
            break
        }
    }
}

extension RCSCConversationViewController: RCSCConversationMessageManagerDelegate {
    
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        if !(message.targetId == communityId && message.channelId == channelId) { return }
        if let content = message.content as? RCSCChannelNoticeMessage {
            handleChannelNoticeMessage(message: content)
        }
        if loadMoreEnable { return }
        RCSCConversationMessageManager.syncCommunityReadStatus(communityId: communityId, channelId: channelId, time: message.sentTime)
        add(message)
        
    }
    
    func onMessageSend(_ message: RCMessage?) {
        if let message = message {
            add(message)
        }
    }
    
    func onFetchHistoryMessagesSuccess(messages: [RCMessage], strategy: RCSCFetchMessageStrategy) {
        let messages = messages.filter { message in
            if let noticeMessage = message.content as? RCSCChannelNoticeMessage, noticeMessage.content?.type == .quit {
                return false
            }
            return true
        }
        SVProgressHUD.dismiss()
        switch strategy {
        case .before: //向上加载
            refreshEnable = messages.count >= 20
            self.messages = messages + self.messages
            var indexPaths = Array<IndexPath>()
            for index in 0..<messages.count { indexPaths.append(IndexPath(row: index, section: 0)) }
            collectionView.insertItems(at: indexPaths)
            //第一次加载历史消息时，加载数据完成滑动到底部
            if (messages.count == self.messages.count && messages.count != 0) {
                collectionView.scrollToItem(at: indexPaths.last!, at: .bottom, animated: false)
            }
            header.endRefreshing()
            break
        case .after://向下加载
            loadMoreEnable = messages.count >= 20
            let count = self.messages.count
            self.messages = self.messages + messages
            var indexPaths = Array<IndexPath>()
            for index in count..<self.messages.count { indexPaths.append(IndexPath(row: index, section: 0)) }
            if let jumpMessage = jumpMessage {
                self.messages.insert(jumpMessage, at: 0)
            }
            collectionView.insertItems(at: indexPaths)
            footer.endRefreshing()
            if jumpMessage != nil || needScrollToTop  {
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            break
        }
        
        //加载到第一条未读消息，清理未读状态
        /*
        if let firstUnreadMessage = firstUnreadMessage {
            for message in self.messages {
                if message.messageUId == firstUnreadMessage.messageUId {
                    clearUnreadStatus()
                }
            }
        }
        */
    }
    
    func deleteMeesage(message: RCMessage) -> Bool {
        return RCSCConversationMessageManager.deleteMessage(messageId: Int64(message.messageId))
    }
    
    func resendMessage(message: RCMessage, type: RCSCMessageType) {
        guard let messageProtocol = message.content as? RCSCMessageProtocol, var pushContent = self.pushContent else { return }
        pushContent.content = messageProtocol.quoteText()
        RCSCConversationMessageManager.resendMessage(message: message, type: type, pushContent: pushContent)
    }
    
    func onMessageModified(_ messages: [RCMessage]!) {
        reloadItems(messages: messages)
    }
    
    func onMessageRecall(_ messages: [RCMessage]!) {
        reloadItems(messages: messages, recall: true)
    }
    
    func onUltraGroupTypingStatusChanged(_ infoArr: [RCUltraGroupTypingStatusInfo]!) {
        if let _ = view.viewWithTag(RCSCMarkMessageHubView.RCSCMarkMessageTagID) {
            typeStatusBarRemakeConstraints(top: RCSCMarkMessageHubView.RCSCMarkMessageContentHeight)
        } else {
            typeStatusBarRemakeConstraints(top: 0)
        }
        for info in infoArr {
            if info.targetId == communityId && info.channelId == channelId {
                RCSCUserInfoCacheManager.getUserInfo(with: communityId, userId: info.userId) {[weak self] userInfo in
                    DispatchQueue.main.async {
                        guard let self = self, let userInfo = userInfo else { return }
                        let text = info.userNumbers == 0 ? "\(userInfo.nickName) 正在输入..." : "\(userInfo.nickName) 等\(info.userNumbers)个人 正在输入..."
                        self.typingStatusBar.show(in: self.view, text: text)
                    }
                }
                break
            }
        }

    }
    
    func syncCommunityReadStatus(_ success: Bool, _ errorCode: RCErrorCode?) {
        debugPrint("sync community read status code: \(errorCode?.rawValue ?? 0)")
    }
}
