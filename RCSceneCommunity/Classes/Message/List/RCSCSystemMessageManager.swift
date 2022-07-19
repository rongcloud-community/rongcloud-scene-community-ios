//
//  RCSCSystemMessageManager.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/4/28.
//

import Foundation


class RCSCSystemMessageManager {
    
    private let manager = RCCoreClient.shared()
    public typealias RCSCSysInitMsgClosure = ([RCMessage]?) -> Void
    
    
    init() {
//        RCCoreClient.shared().logLevel = .log_Level_Verbose
        RCCoreClient.shared().registerMessageType(RCSCSystemMessage.self)
    }
    
    
    /// 获取初始化历史系统消息
    /// - Parameter callBackMsgArr: 成功回调
    func fetchInitializedHistoryMessage(_ callBackMsgArr:RCSCSysInitMsgClosure?) {
        let msgArr =   manager?.getHistoryMessages(.ConversationType_SYSTEM, targetId: "_SYSTEM_", oldestMessageId: -1, count: 20) as? [RCMessage]
        if let action = callBackMsgArr {
            action(msgArr)
        }        
    }
    
    
    /// 获取更多历史消息
    /// - Parameters:
    ///   - messageId: 哨兵消息ID
    ///   - callBackMsgArr: 成功回调
    func fetchSystemHistoryMessage(_ messageId:Int,
                                callBackMsgArr:RCSCSysInitMsgClosure?) {
        let msgArr =   manager?.getHistoryMessages(.ConversationType_SYSTEM, targetId: "_SYSTEM_", oldestMessageId: messageId, count: 20) as? [RCMessage]
        if let action = callBackMsgArr {
            action(msgArr)
        }
    }
    

    
}
