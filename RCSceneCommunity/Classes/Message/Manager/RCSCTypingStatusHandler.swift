//
//  RCSCTypingStatusHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation

class RCSCTypingStatusHandler: NSObject {
    weak var delegate: RCSCConversationMessageManagerDelegate?
    let channel = RCChannelClient.sharedChannelManager()!
    
    func sendTypingMessage(communityId: String, channelId: String) {
        channel.sendUltraGroupTypingStatus(communityId, channelId: channelId, typingStatus: .text) {
            debugPrint("正在输入消息发送成功")
        } error: { code in
            debugPrint("正在输入消息发送失败 code：\(code.rawValue)")
        }
    }
}

extension RCSCTypingStatusHandler: RCUltraGroupTypingStatusDelegate {
    func onUltraGroupTypingStatusChanged(_ infoArr: [RCUltraGroupTypingStatusInfo]!) {
        DispatchQueue.main.async {
            self.delegate?.onUltraGroupTypingStatusChanged(infoArr)
        }
    }
}

extension RCSCConversationMessageManager {
    static func sendTypingMessage(communityId: String, channelId: String) {
        self.manager.typingStatusHandler.sendTypingMessage(communityId: communityId, channelId: channelId)
    }
}
