//
//  RCSCMarkMessageViewController+Message.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/12.
//
import Foundation
import Photos
import SVProgressHUD

extension RCSCMarkMessageViewController {
    
    func insert(_ message: RCSCMarkMessage) {
        messages.insert(message, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.insertItems(at: [indexPath])
    }
    
    private func  reloadItems(messages: Array<RCSCMarkMessage>) {
        var indexPaths = Array<IndexPath>()
        for message in messages {
            for (index,value) in self.messages.enumerated() {
                if (value.messageUid == message.messageUid) {
                    self.messages[index] = message
                    indexPaths.append(IndexPath(row: index, section: 0))
                    break
                }
            }
        }
        self.collectionView.reloadItems(at: indexPaths)
    }
}

extension RCSCMarkMessageViewController: RCSCConversationMessageManagerDelegate {
    
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        if message.targetId == communityId && message.channelId == channelId {
            guard let channelMessage = message.content as? RCSCChannelNoticeMessage,
                  channelMessage.content?.type == RCSCChannelNoticeMessageType.mark,
                  let messageUid = channelMessage.content?.messageUid,
                  let rcMessage = RCSCConversationMessageManager.fetchMessageByMessageUid(messageUid: messageUid)
            else { return }
            let markMessage = RCSCMarkMessage(uid: rcMessage.senderUserId, channelUid: rcMessage.channelId, messageUid: rcMessage.messageUId)
            insert(markMessage)
        }
    }
    
    func deleteMeesage(message: RCMessage) -> Bool {
        return RCSCConversationMessageManager.deleteMessage(messageId: Int64(message.messageId))
    }
    
    func onMessageModified(_ messages: [RCMessage]!) {
        reloadItems(messages: convertMessages(messages: messages))
    }
    
    func onMessageRecall(_ messages: [RCMessage]!) {
        reloadItems(messages: convertMessages(messages: messages))
    }
    
    func onFetchMarkMessages(_ messages: [RCSCMarkMessage]!, _ loadMore: Bool) {
        if loadMore {
            footer.endRefreshing()
        }
        
        if messages.count < pageSize {
            loadMoreEnable = false
            if loadMore {
                SVProgressHUD.showInfo(withStatus: "没有更多数据了")
            }
        }
        
        var result = messages.filter { markMessageInfo in
            guard let message = RCSCConversationMessageManager.getMessageByUid(messageUid: markMessageInfo.messageUid),
                  !(message.content is RCRecallNotificationMessage)
            else {
                return false
            }
            return true
        }
        
        if self.messages.count == 0 {
            //第一次拉取列表数据
            self.messages = result
        } else {
            //loadMore
            self.messages = self.messages + result
        }
        
        collectionView.reloadData()
    }
    
    
    private func convertMessages(messages: Array<RCMessage>) -> Array<RCSCMarkMessage> {
        var markMessages = Array<RCSCMarkMessage>()
        for message in messages {
            let markMessage = RCSCMarkMessage(uid: message.senderUserId, channelUid: message.channelId, messageUid: message.messageUId)
            markMessages.append(markMessage)
        }
        return markMessages
    }
}

