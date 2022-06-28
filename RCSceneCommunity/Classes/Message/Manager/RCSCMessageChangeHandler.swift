//
//  RCSCMessageChangeHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation

class RCSCMessageChangeHandler: NSObject {
    weak var delegate: RCSCConversationMessageManagerDelegate?
}

extension RCSCMessageChangeHandler: RCUltraGroupMessageChangeDelegate {
    
    func onUltraGroupMessageModified(_ messages: [RCMessage]!) {
        runOnMainQueue {
            self.delegate?.onMessageModified(messages)
        }
    }
    
    func onUltraGroupMessageRecalled(_ messages: [RCMessage]!) {
        if messages.count > 0 {
            runOnMainQueue {
                self.delegate?.onMessageRecall(messages)
            }
        }
    }
    
    func onUltraGroupMessageExpansionUpdated(_ messages: [RCMessage]!) {
        
    }
}
