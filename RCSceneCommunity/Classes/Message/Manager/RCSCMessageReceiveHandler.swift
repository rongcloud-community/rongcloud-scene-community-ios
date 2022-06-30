//
//  RCSCMessageReceiveHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation
import SVProgressHUD

let RCSCCommunityDetailChangedNotification = Notification.Name(rawValue: "RCSCCommunityDetailChangedNotification")

let RCSCCommunityReceiveSystemMessageNotification = Notification.Name(rawValue: "RCSCCommunityReceiveSystemMessageNotification")

let RCSCCommunityModifyMuteStatusNotification = Notification.Name(rawValue: "RCSCCommunityModifyMuteStatusNotification")

//FIXME: 经过自测,切换审核类型 ,测试断点到消息,后台仅仅是发送  ConversationType_ULTRAGROUP = 10, 且 RCMic:ChannelNotice; 并不触发 system 消息.
// 这里临时处理.触发本地通知,舍弃
let RCSCCommunityReceiveSystemMessageNotificationLocal = Notification.Name(rawValue: "RCSCCommunityReceiveSystemMessageNotificationLocal")
// 或者. ConversationType_ULTRAGROUP = 10, 且 RCMic:ChannelNotice 中添加一个通知
let RCSCCommunityReceiveSystemMessageNotificationRCMicChannelNotice = Notification.Name(rawValue: "RCSCCommunityReceiveSystemMessageNotificationRCMicChannelNotice")



let RCSCDeleteChannelsKey = "RCSCDeleteChannelsKey"

let RCSCCommunityChangedMessageKey = "RCSCCommunityChangedMessageKey"

let RCSCCommunitySystemMessageIdKey = "RCSCCommunitySystemMessageCommunityIdKey"

extension RCSCSystemMessageType {
    func handle(message: String?, communityId: String, fromUserID: String) {
        switch self {
        case .dissolve:
            NotificationCenter.default.post(name: RCSCCommunityReceiveSystemMessageNotification, object: self, userInfo: [RCSCCommunitySystemMessageIdKey:communityId])
            handleAlertNotification(message: message, communityId: communityId, fromUserID: fromUserID, type: self)
            break
        case .quit:
            NotificationCenter.default.post(name: RCSCCommunityReceiveSystemMessageNotification, object: self, userInfo: [RCSCCommunitySystemMessageIdKey:communityId])
            SVProgressHUD.showInfo(withStatus: "退出社区成功")
            break
        case .kickOut:
            NotificationCenter.default.post(name: RCSCCommunityReceiveSystemMessageNotification, object: self, userInfo: [RCSCCommunitySystemMessageIdKey:communityId])
            handleAlertNotification(message: message, communityId: communityId, fromUserID: fromUserID, type: self)
            break
        case .reject, .joined:
            NotificationCenter.default.post(name: RCSCCommunityReceiveSystemMessageNotification, object: self, userInfo: [RCSCCommunitySystemMessageIdKey:communityId])
        default:
            break
        }
    }
    
    func handleAlertNotification(message: String?, communityId: String, fromUserID: String, type: RCSCSystemMessageType) {
        guard let _ = RCSCCommunityManager.manager.detailData else { return }
        if communityId == RCSCCommunityManager.manager.currentDetail.uid {
            if let viewController = RCSCCommunityManager.manager.currentConversationViewController {
                let title = type == .dissolve ? "当前社区已经解散" : "您已经被踢出该社区"
                var alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "确定", style: .destructive) { [weak viewController] _ in
                    guard let viewController = viewController else { return }
                    viewController.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                viewController.present(alert, animated: true, completion: nil)
                return
            }
        }
        if let user = RCSCUser.user, fromUserID.count > 0, user.userId != fromUserID {
            SVProgressHUD.showInfo(withStatus: message ?? "")
        }
    }
}


extension RCSCChannelNoticeMessageType {
    func handleCommunityChannelNoticeMessage(noticeMessage: RCSCChannelNoticeMessage, communityId: String) {
        let currentCommunityId = RCSCCommunityManager.manager.currentDetail.uid
        switch self {
        case .mark, .deleteMark:
            RCSCMarkMessageHub.receiveMarkMessage(markMessage: noticeMessage)
            break
        case .mute, .releaseMute:
            if communityId == currentCommunityId{
                RCSCCommunityDetailApi(communityId: communityId).fetch().success {object in
                    guard let obj = object else { return }
                    DispatchQueue.main.async {
                        RCSCCommunityManager.manager.currentDetail.communityUser.shutUp = obj.communityUser.shutUp
                        NotificationCenter.default.post(name: RCSCCommunityModifyMuteStatusNotification, object: RCSCCommunityManager.manager.currentDetail.communityUser.shutUp, userInfo: nil)
                    }
                }
            }
            break
        case .join:
            //FIXME: 经过自测,切换社区不审核 ,测试断点到消息,后台仅仅是发送  ConversationType_ULTRAGROUP = 10, 且 RCMic:ChannelNotice; 并不触发 system 消息
            NotificationCenter.default.post(name: RCSCCommunityReceiveSystemMessageNotificationRCMicChannelNotice, object: nil,  userInfo: [RCSCCommunitySystemMessageIdKey:communityId])
        default:
            break
        }
    }
}

class RCSCMessageReceiveHandler: NSObject {
    
    weak var delegate: RCSCConversationMessageManagerDelegate?
    
}

extension RCSCMessageReceiveHandler: RCIMClientReceiveMessageDelegate {
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        DispatchQueue.main.async { [weak self] in
            switch message.conversationType {
            case .ConversationType_ULTRAGROUP:
                self?.handleCommunityMessage(message, left: nLeft, object: object)
                break
            case .ConversationType_SYSTEM:
                self?.handleSystemMessage(message, left: nLeft, object: object)
                break
            default:
                break
            }
        }
    }
    
    private func handleCommunityMessage(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        if let changeMessage = message.content as? RCSCChangeMessage {
            handleChangeMessage(changeMessage)
        } else if let updateUserInfoMessage = message.content as? RCSCUserInfoUpdateMessage {
            handleUpdateUserInfoMessage(updateUserInfoMessage, message.targetId)
        } else {
            if let noticeMessage = message.content as? RCSCChannelNoticeMessage {
                noticeMessage.content?.type?.handleCommunityChannelNoticeMessage(noticeMessage: noticeMessage, communityId: message.targetId)
            }
                
            NotificationCenter.default.post(name: RCSCCommunityBadgeUpdateNotification, object: true, userInfo: [kRCSCCommunityListIdKey: message.targetId as String])
            RCSCLocalNotificationCenter.postNotification(message: message)
            self.delegate?.onReceived(message, left: nLeft, object: object)
        }
        
    }
    
    private func handleSystemMessage(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        if let communitySystemMessage = message.content as? RCSCSystemMessage, let content = communitySystemMessage.content {
            content.type?.handle(message: communitySystemMessage.content?.message, communityId: content.communityUid ?? "", fromUserID: content.fromUserId ?? "")
            self.delegate?.onReceivedSystem(message, left: nLeft, object: object)
        }
    }
    
    private func handleChangeMessage(_ changeMessage: RCSCChangeMessage) {
        if let communityId = changeMessage.content?.communityUid {
            var userInfo = Dictionary<String, Any>()
            if let message = changeMessage.content?.message, message.count > 0 {
                userInfo[RCSCCommunityChangedMessageKey] = message
            }
            if let channels = changeMessage.content?.channelUids, channels.count > 0 {
                userInfo[RCSCDeleteChannelsKey] = channels
            }
            NotificationCenter.default.post(name: RCSCCommunityDetailChangedNotification, object: communityId, userInfo: userInfo)
        }
    }
    
    func handleUpdateUserInfoMessage(_ updateUserInfoMessage: RCSCUserInfoUpdateMessage, _ targetId: String) {
        guard let content = updateUserInfoMessage.content else { return }
        if let userId = content.userId {
            let userInfo = RCSCUserInfoCacheManager.getUserInfo(with: targetId, userId: userId, completion: { userInfo in
                guard let userInfo = userInfo else { return }
                DispatchQueue.main.async {
                    RCSCUserInfoCacheManager.setUserInfo(with: targetId, userId: userId, userInfo: userInfo)
                    NotificationCenter.default.post(name: RCSCUserInfoCacheUpdateNotification, object: userInfo, userInfo: [kCacheCommunityIdKey: targetId, kCacheUserIdKey: userId])
                }
            })
            
            if let userInfo = userInfo, let modifyType =  content.type {
                if modifyType == .name {
                    userInfo.nickName = content.nickName!
                } else {
                    userInfo.portrait = content.portrait!
                }
                RCSCUserInfoCacheManager.setUserInfo(with: targetId, userId: userId, userInfo: userInfo)
                NotificationCenter.default.post(name: RCSCUserInfoCacheUpdateNotification, object: userInfo, userInfo: [kCacheCommunityIdKey: targetId, kCacheUserIdKey: userId])
            }
        }
    }
}

