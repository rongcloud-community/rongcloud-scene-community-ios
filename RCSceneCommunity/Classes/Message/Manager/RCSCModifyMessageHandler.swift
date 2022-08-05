//
//  RCSCModifyMessageHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/29.
//

import Foundation
import SVProgressHUD
import RongCloudOpenSource

class RCSCModifyMessageHandler: NSObject {
    
    private var user: RCSCUser {
        get {
            assert(RCSCUser.user != nil, "当前用户登录状态异常")
            return RCSCUser.user!
        }
    }
    
    private let manager = RCChannelClient.sharedChannelManager()
    
    private let core = RCCoreClient.shared()
    
    weak var delegate: RCSCConversationMessageManagerDelegate?
    
    func deleteMessage(messageId: Int64) -> Bool {
        return core.deleteMessages([NSNumber.init(value: messageId)])
    }
    
    func modifyMessage(messageUid: String, text: String, atUsers: Array<RCSCCommunityUser>?, completion: @escaping RCSCSendMessageCompletion) {
        guard let message = RCSCConversationMessageManager.getMessageByUid(messageUid: messageUid) else { return }
        
        var messageContent = RCMessageContent()
        
        if var textMessage = message.content as? RCTextMessage {
            textMessage.content = text
            messageContent = textMessage
        } else if var refMessage = message.content as? RCReferenceMessage {
            refMessage.content = text
            messageContent = refMessage
        }
        
        messageContent.senderUserInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: user.portrait)
        
        manager.modifyUltraGroupMessage(messageUid, messageContent: messageContent) {
            print("消息修改成功")
            runOnMainQueue {
                completion(true,RCErrorCode.RC_SUCCESS)
            }
            
        } error: { code in
            runOnMainQueue {
                completion(false,code)
            }
        }
    }
    
    func recallMessage(message: RCMessage) {
        if message.messageUId != nil {
            RCSCCommunityDeleteMarkApi(messageUid: message.messageUId).deleteMark().success { _ in
                debugPrint("delete mark message success")
            }.failed { error in
                debugPrint("delete mark message fail error \(error.desc)")
            }
            _recallMessage(message: message)
        } else {
            debugPrint("recall message failed, message uid is nil")
        }
    }
    
    private func _recallMessage(message: RCMessage) {
        manager.recallUltraGroupMessage(message) { messageId in
            debugPrint("recall success messageId \(messageId)")
        } error: { code in
            print("recall failed code: \(code.rawValue)")
            SVProgressHUD.showError(withStatus: "撤回消息失败 code：\(code.rawValue)")
        }
    }
}

extension RCSCConversationMessageManager {
    //删除消息
    static func deleteMessage(messageId: Int64) -> Bool {
        return Self.manager.modifyMessageHandler.deleteMessage(messageId: messageId)
    }
    
    //修改消息
    static func modifyMessage(messageUid: String, text: String, atUsers: Array<RCSCCommunityUser>?, completion: @escaping RCSCSendMessageCompletion) {
        Self.manager.modifyMessageHandler.modifyMessage(messageUid: messageUid, text: text, atUsers: atUsers, completion: completion)
    }
    
    //撤回
    static func recallMessage(message: RCMessage) {
        Self.manager.modifyMessageHandler.recallMessage(message: message)
    }
}
