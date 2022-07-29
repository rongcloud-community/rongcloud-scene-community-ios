//
//  RCSCSendMessageHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation
import SVProgressHUD
import UIKit

let RCSCSendMessageCompletionNotification = Notification.Name(rawValue: "RCSCSendMessageCompletionNotification")

let RCSCMediaDataUploadProgressNotification = Notification.Name(rawValue: "RCSCMediaDataUploadProgressNotification")

typealias RCSCSendMessageCompletion = ((Bool,RCErrorCode) -> Void)

struct RCSCPushContent {
    let communityName: String
    let channelName: String
    let senderName: String
    var content: String?
}

func runOnMainQueue(_ block: @escaping (()->())) {
    DispatchQueue.main.async {
        block()
    }
}

class RCSCSendMessageHandler: NSObject {
    
    private var user: RCSCUser {
        get {
            assert(RCSCUser.user != nil, "当前用户登录状态异常")
            return RCSCUser.user!
        }
    }
    
    private let channel = RCChannelClient.sharedChannelManager()!
    
    private let core = RCCoreClient.shared()!
    
    weak var delegate: RCSCConversationMessageManagerDelegate?
    
    func getMentionedInfoAndEXDictionaryJsonString(atUsers: Array<RCSCCommunityUser>) -> (info: RCMentionedInfo?, jsonString: String?) {
        
        guard atUsers.count != 0 else { return (nil,nil) }
        
        var info: RCMentionedInfo?
        var jsonString: String?
        var dictionary = Dictionary<String, Any>()
        
        if atUsers.count > 0 {
            var uids = Array<String>()
            for user in atUsers {
                dictionary[user.userUid] = user.name
                uids.append(user.userUid)
            }
            if uids.count > 0 {
                info = RCMentionedInfo(mentionedType: .mentioned_Users, userIdList: uids, mentionedContent: "")
                jsonString = dictionary.getJsonString()
            }
        }
        
        return (info,jsonString)
    }
    
    //发送文本消息
    func sendTextMessage(text: String, communityId: String, channelId: String, atUsers: Array<RCSCCommunityUser>?, pushContent: RCSCPushContent) {
        let textMessage = RCTextMessage(content: text)!
        
        sendTextMessage(content: textMessage, communityId: communityId, channelId: channelId, atUsers: atUsers, pushContent: pushContent)
    }
    
    //发送图片消息
    func sendImageMessage(image: UIImage, communityId: String, channelId: String, pushContent: RCSCPushContent) {
        guard let data = image.sd_imageData(),
              let imageMessage = RCImageMessage.init(imageData: data)
        else {
            return SVProgressHUD.showError(withStatus: "发送图片消息失败, 请检查登录状态，图片数据是否获取成功")
        }
        imageMessage.isFull = true
        sendMediaMessage(content: imageMessage, communityId: communityId, channelId: channelId, pushContent: pushContent)
    }
    
    //发送视频消息
    func sendVideoMessage(videoPath: String, thumbnail: UIImage, duration: UInt, communityId: String, channelId: String, pushContent: RCSCPushContent) {
        guard let videoMessage = RCSightMessage.init(localPath: videoPath, thumbnail: thumbnail, duration: duration) else {
            return SVProgressHUD.showError(withStatus: "发送视频消息失败, 请检查登录状态，视频数据是否获取成功")
        }
        sendMediaMessage(content: videoMessage, communityId: communityId, channelId: channelId, pushContent: pushContent)
    }
    
    //重发消息
    func resendMessage(message: RCMessage, type: RCSCMessageType, pushContent: RCSCPushContent) {
        if type == .text {
            if let content = message.content as? RCTextMessage {
                sendTextMessage(content: content, communityId: message.targetId, channelId: message.channelId, atUsers: nil, pushContent: pushContent)
            }
        } else if type == .image || type == .video {
            if let content = message.content as? RCMediaMessageContent {
                content.localPath = content.realCommunityPath()
                sendMediaMessage(content: content, communityId: message.targetId, channelId: message.channelId, pushContent: pushContent)
            }
        }
    }
    
    func sendQuoteMessage(quoteMessage: RCMessage, text: String, atUsers: Array<RCSCCommunityUser>?, pushContent: RCSCPushContent) {
        let newMessage = RCReferenceMessage.init()
        newMessage.content = text
        newMessage.referMsgUserId = user.userId
        newMessage.referMsg = quoteMessage.content
        newMessage.referMsgUid = quoteMessage.messageUId
        newMessage.senderUserInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: user.portrait)
        
        var jsonString: String?
        
        if let atUsers = atUsers {
            let result = getMentionedInfoAndEXDictionaryJsonString(atUsers: atUsers)
            if let info = result.info, let jString = result.jsonString {
                newMessage.mentionedInfo = info
                jsonString = jString
            }
        }
        
        guard let msg = RCMessage.init(type: .ConversationType_ULTRAGROUP, targetId: quoteMessage.targetId, channelId: quoteMessage.channelId, direction: .MessageDirection_SEND, content: newMessage) else {
            debugPrint("消息初始化失败")
            return
        }
        
        if let jsonString = jsonString {
            msg.expansionDic = [kConversationAtMessageTypeKey: jsonString]
        }
        
        core.send(msg, pushContent: nil, pushData: nil) {[weak self] message in
            guard let message = message else { return }
            var messageId = message.messageId
            DispatchQueue.main.async {
                self?.delegate?.onMessageSend(message)
                NotificationCenter.default.post(name: RCSCSendMessageCompletionNotification, object: (messageId, 0))
            }
        } errorBlock: {[weak self] code, message in
            guard let message = message else { return }
            var messageId = message.messageId
            DispatchQueue.main.async {
                self?.delegate?.onMessageSend(message)
                NotificationCenter.default.post(name: RCSCSendMessageCompletionNotification, object: (messageId, code.rawValue))
            }
        }
    }
    
    //MARK: Private
    //发送文本消息
    private func sendTextMessage(content: RCTextMessage, communityId: String, channelId: String, atUsers: Array<RCSCCommunityUser>?, pushContent: RCSCPushContent) {
        
        content.senderUserInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: user.portrait)
    
        var jsonString: String?
        
        if let atUsers = atUsers {
            let result = getMentionedInfoAndEXDictionaryJsonString(atUsers: atUsers)
            if let info = result.info, let jString = result.jsonString {
                content.mentionedInfo = info
                jsonString = jString
            }
        }
        
        guard let msg = RCMessage.init(type: .ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, direction: .MessageDirection_SEND, content: content) else {
            return
        }
        var messagePushConfig = RCMessagePushConfig()
        messagePushConfig.pushTitle = "\(pushContent.communityName)#\(pushContent.channelName)"
        messagePushConfig.pushContent = "\(pushContent.senderName)：\(pushContent.content ?? "")"
        msg.messagePushConfig = messagePushConfig
        if let jsonString = jsonString {
            msg.canIncludeExpansion = true
            msg.expansionDic = [kConversationAtMessageTypeKey: jsonString]
        }
        
        let res = core.send(msg, pushContent: nil, pushData: nil) { message in
            guard let message = message else { return }
            var messageId = message.messageId
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: RCSCSendMessageCompletionNotification, object: (messageId, 0))
            }
        } errorBlock: { code, message in
            guard let message = message else { return }
            var messageId = message.messageId
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: RCSCSendMessageCompletionNotification, object: (messageId, code.rawValue))
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.onMessageSend(res)
        }
    }
    
    //发送多媒体消息
    private func sendMediaMessage(content: RCMediaMessageContent, communityId: String, channelId: String, pushContent: RCSCPushContent) {
        content.senderUserInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: user.portrait)
        //发送成功之后要删除当前缓存的资源文件
        let mediaPath = content.localPath
        
        guard let msg = RCMessage.init(type: .ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, direction: .MessageDirection_SEND, content: content) else {
            return
        }
        
        var messagePushConfig = RCMessagePushConfig()
        messagePushConfig.pushTitle = "\(pushContent.communityName)#\(pushContent.channelName)"
        messagePushConfig.pushContent = "\(pushContent.senderName)：\(pushContent.content ?? "")"
        msg.messagePushConfig = messagePushConfig
        
        let res = core.sendMediaMessage(msg, pushContent: nil, pushData: nil) { progress, message in
            guard let message = message else { return }
            runOnMainQueue {
                NotificationCenter.default.post(name: RCSCMediaDataUploadProgressNotification, object: (message.messageId,progress))
            }
        } successBlock: { message in
            guard let message = message else { return }
            runOnMainQueue {
                //let message = self?.core.getMessage(messageId)
                FileManager.default.deleteMedia(mediaPath: mediaPath)
                NotificationCenter.default.post(name: RCSCSendMessageCompletionNotification, object: (message.messageId, 0))
                
            }
        } errorBlock: {code, message in
            guard let message = message else { return }
            runOnMainQueue {
                NotificationCenter.default.post(name: RCSCSendMessageCompletionNotification, object: (message.messageId, code.rawValue))
            }
        } cancel: { msg in
            
        }
        
        DispatchQueue.main.async {
            self.delegate?.onMessageSend(res)
        }
    }
}

extension RCSCConversationMessageManager {
    //发送文本消息
    static func sendTextMessage(text: String, communityId: String, channelId: String, atUsers: Array<RCSCCommunityUser>?, pushContent: RCSCPushContent) {
        Self.manager.sendMessageHandler.sendTextMessage(text: text, communityId: communityId, channelId: channelId, atUsers: atUsers, pushContent: pushContent)
    }
    
    //发送图片消息
    static func sendImageMessage(image: UIImage, communityId: String, channelId: String, pushContent: RCSCPushContent) {
        Self.manager.sendMessageHandler.sendImageMessage(image: image, communityId: communityId, channelId: channelId, pushContent: pushContent)
    }
    
    //发送视频消息
    static func sendVideoMessage(videoPath: String, thumbnail: UIImage, duration: UInt, communityId: String, channelId: String, pushContent: RCSCPushContent) {
        Self.manager.sendMessageHandler.sendVideoMessage(videoPath: videoPath, thumbnail: thumbnail, duration: duration, communityId: communityId, channelId: channelId, pushContent: pushContent)
    }
    
    //消息失败重发
    static func resendMessage(message: RCMessage, type: RCSCMessageType, pushContent: RCSCPushContent) {
        Self.manager.sendMessageHandler.resendMessage(message: message, type: type, pushContent: pushContent)
    }
    
    //发送引用消息
    static func sendQuoteMessage(quoteMessage: RCMessage, text: String, atUsers: Array<RCSCCommunityUser>?, pushContent: RCSCPushContent) {
        Self.manager.sendMessageHandler.sendQuoteMessage(quoteMessage: quoteMessage, text: text, atUsers: atUsers, pushContent: pushContent)
    }
}
