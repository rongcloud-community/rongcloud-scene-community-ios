//
//  RCSCMessageManager.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation
import RongCloudOpenSource

typealias MsgMgr = RCSCConversationMessageManager

class RCSCConversationMessageManagerDelegateBox {
  weak var value : RCSCConversationMessageManagerDelegate?
  init (value: RCSCConversationMessageManagerDelegate?) {
    self.value = value
  }
}

class RCSCConversationMessageManager: NSObject {
    
    //会话消息 mgr 实例
    static let manager = RCSCConversationMessageManager()
    
    //已读相关处理
    let readTimeHandler = RCSCReadTimeHandler()
    
    //输入状态
    let typingStatusHandler = RCSCTypingStatusHandler()
    
    //消息变动receiver  撤回  修改  相关回调会在此类中处理
    let messageChangeHandler = RCSCMessageChangeHandler()
    
    //消息 receiver
    let messageReceiveHandler = RCSCMessageReceiveHandler()
    
    //文本、图片、视频、引用消息会在此类发送
    let sendMessageHandler = RCSCSendMessageHandler()
    
    //历史消息拉取
    let historyMessageHandler = RCSCHistoryMessageHandler()
    
    //消息修改
    let modifyMessageHandler = RCSCModifyMessageHandler()
    
    //更新用户信息
    let userInfoDataSource = RCSCUserInfoDataSource()
    
    //处理未读消息数
    let unreadCountHandler = RCSCUnreadCountHandler()
    
    //处理远程通知。目前只有设置功能
    let remoteNotificationHandler = RCSCRemoteNotificationHandler()
    
    // 所有 handler 处理之后的结果会通过此 deletae 回调
    // 接收回调的 listener 只处理自己关心的回调即可
    
    var delegates = Array<RCSCConversationMessageManagerDelegateBox>()
    
    private override init() {
        super.init()
        setHandlerDelegate()
        RCCoreClient.shared().logLevel = .log_Level_Verbose
        RCCoreClient.shared().registerMessageType(RCSCSystemMessage.self)
        RCCoreClient.shared().registerMessageType(RCSCUserInfoUpdateMessage.self)
        RCCoreClient.shared().registerMessageType(RCSCDeleteMessage.self)
        RCCoreClient.shared().registerMessageType(RCSCChangeMessage.self)
        RCCoreClient.shared().registerMessageType(RCSCChannelNoticeMessage.self)
        //图片消息
        RCCoreClient.shared().registerMessageType(RCImageMessage.self)
        //视频消息
        RCCoreClient.shared().registerMessageType(RCSightMessage.self)
        //引用消息
        RCCoreClient.shared().registerMessageType(RCReferenceMessage.self)
        
        RCChannelClient.sharedChannelManager().setRCUltraGroupReadTimeDelegate(readTimeHandler)
        RCChannelClient.sharedChannelManager().setRCUltraGroupTypingStatusDelegate(typingStatusHandler)
        RCChannelClient.sharedChannelManager().setRCUltraGroupMessageChangeDelegate(messageChangeHandler)
        RCCoreClient.shared().add(messageReceiveHandler)
        RCKitConfig.default().message.disableMessageAlertSound = true
        if RCIM.shared().userInfoDataSource == nil {
            RCIM.shared().userInfoDataSource = userInfoDataSource
        }
    }
    
    private func setHandlerDelegate() {
        readTimeHandler.delegate = self
        typingStatusHandler.delegate = self
        messageChangeHandler.delegate = self
        messageReceiveHandler.delegate = self
        sendMessageHandler.delegate = self
        historyMessageHandler.delegate = self
        modifyMessageHandler.delegate = self
    }
    
    static func initialized() {
        let _ = Self.manager
    }
    
    static func setDelegate(delegate: RCSCConversationMessageManagerDelegate) {
        let box = RCSCConversationMessageManagerDelegateBox(value: delegate)
        Self.manager.delegates.append(box)
    }
}

extension RCSCConversationMessageManager: RCSCConversationMessageManagerDelegate {
    
    func onUltraGroupReadTimeReceived(_ targetId: String!, channelId: String!, readTime: Int64) {
        for box in delegates {
            box.value?.onUltraGroupReadTimeReceived(targetId, channelId: channelId, readTime: readTime)
        }
    }
    
    func onUltraGroupTypingStatusChanged(_ infoArr: [RCUltraGroupTypingStatusInfo]!) {
        for box in delegates {
            box.value?.onUltraGroupTypingStatusChanged(infoArr)
        }
    }
    
    func onUltraGroupMessageModified(_ messages: [RCMessage]!) {
        for box in delegates {
            box.value?.onUltraGroupMessageModified(messages)
        }
    }
    
    func onUltraGroupMessageRecalled(_ messages: [RCMessage]!) {
        for box in delegates {
            box.value?.onUltraGroupMessageRecalled(messages)
        }
    }
    
    func onUltraGroupMessageExpansionUpdated(_ messages: [RCMessage]!) {
        for box in delegates {
            box.value?.onUltraGroupMessageExpansionUpdated(messages)
        }
    }
    
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        for box in delegates {
            box.value?.onReceived(message, left: nLeft, object: object)
        }
    }
    func onReceivedSystem(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        for box in delegates {
            box.value?.onReceivedSystem(message, left: nLeft, object: object)
        }
    }
    
    func onMessageSend(_ message: RCMessage?) {
        for box in delegates {
            box.value?.onMessageSend(message)
        }
    }
    
    func onFetchHistoryMessagesSuccess(messages:Array<RCMessage>, strategy: RCSCFetchMessageStrategy) {
        for box in delegates {
            box.value?.onFetchHistoryMessagesSuccess(messages: messages, strategy: strategy)
        }
    }
    
    func onMessageModified(_ messages: [RCMessage]!) {
        for box in delegates {
            box.value?.onMessageModified(messages)
        }
    }
    
    func onMessageRecall(_ messages: [RCMessage]!) {
        for box in delegates {
            box.value?.onMessageRecall(messages)
        }
    }
    
    func onFetchMarkMessages(_ messages: [RCSCMarkMessage]!, _ loadMore: Bool) {
        for box in delegates {
            box.value?.onFetchMarkMessages(messages,loadMore)
        }
    }
}
