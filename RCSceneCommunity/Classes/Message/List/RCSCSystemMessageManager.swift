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
    
    func fetchInitializedHistoryMessage(_ callBackMsgArr:RCSCSysInitMsgClosure?)  {
        let msgArr =   manager?.getHistoryMessages(.ConversationType_SYSTEM, targetId: "_SYSTEM_", oldestMessageId: -1, count: 20) as? [RCMessage]
        if let action = callBackMsgArr {
            action(msgArr)
        }        
    }
    
    func fetchSystemHistoryMessage(_ messageId:Int, callBackMsgArr:RCSCSysInitMsgClosure?){
        let msgArr =   manager?.getHistoryMessages(.ConversationType_SYSTEM, targetId: "_SYSTEM_", oldestMessageId: messageId, count: 20) as? [RCMessage]
        if let action = callBackMsgArr {
            action(msgArr)
        }
    }
    

    
}
