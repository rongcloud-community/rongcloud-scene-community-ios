//
//  RCSCReadTimeHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation

class RCSCReadTimeHandler: NSObject {
    weak var delegate: RCSCConversationMessageManagerDelegate?
    let channelClient = RCChannelClient.sharedChannelManager()
    
    func syncCommunityReadStatus(communityId: String, channelId: String, time: Int64) {
        channelClient.syncUltraGroupReadStatus(communityId, channelId: channelId, time: time) { [weak self] in
            self?.delegate?.syncCommunityReadStatus(true, nil)
        } error: { [weak self] code in
            self?.delegate?.syncCommunityReadStatus(false, code)
        }

    }
}

extension RCSCReadTimeHandler: RCUltraGroupReadTimeDelegate {
    func onUltraGroupReadTimeReceived(_ targetId: String!, channelId: String!, readTime: Int64) {
        
    }
}


extension RCSCConversationMessageManager {
    static func syncCommunityReadStatus(communityId: String, channelId: String, time: Int64) {
        Self.manager.readTimeHandler.syncCommunityReadStatus(communityId: communityId, channelId: channelId, time: time)
    }
}
