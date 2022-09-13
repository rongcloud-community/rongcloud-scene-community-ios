//
//  RCSCUnreadCountHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/20.
//


struct RCSCUnreadBadge {
    var current: Int32 = 0
    var original: Int32 = 0
}

class RCSCUnreadCountHandler: NSObject {
    
    private let channel = RCChannelClient.sharedChannelManager()
    
    private let core = RCCoreClient.shared()
    
    private var cache = Dictionary<String, RCSCUnreadBadge>()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleCommunity(notification:)), name: RCSCCommunityToggleNotification, object: nil)
    }
    
    @objc private func toggleCommunity(notification: Notification) {
        guard let userInfo = notification.userInfo, let communityId = userInfo[kRCSCCommunityListIdKey] as? String, communityId.count > 0 else {
            return
        }
        NotificationCenter.default.post(name: RCSCCommunityBadgeUpdateNotification, object: false, userInfo: [kRCSCCommunityListIdKey: communityId])
    }
    
    func isShowRedDot(communityId: String) -> Bool {
        
        let unreadCount = fetchCommunityUnreadCount(communityId: communityId)
        
        var badge = cache[communityId] ?? RCSCUnreadBadge()
        
        badge.original = badge.current
        badge.current = unreadCount
        
        cache[communityId] = badge
        
        return badge.current > badge.original
    }
    
    func clearUnreadCount(communityId: String, channelId: String, time: Int64) -> Bool {
        return channel.clearMessagesUnreadStatus(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, time: time)
    }
    
    func fetchFirstUnreadMessage(communityId: String, channelId: String) -> RCMessage? {
        return channel.getFirstUnreadMessage(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId)
    }
    
    private func fetchCommunityUnreadCount(communityId: String) -> Int32 {
        var unreadCount: Int32 = 0
        if let res = channel.getConversationList(forAllChannel: .ConversationType_ULTRAGROUP, targetId: communityId) {
            for conversation in res {
                if conversation.channelId?.count == 0 { continue }
                unreadCount = unreadCount + conversation.unreadMessageCount
            }
        }
        return unreadCount
    }
    
}

extension RCSCConversationMessageManager {
    static func isShowRedDot(communityId: String) -> Bool {
        return Self.manager.unreadCountHandler.isShowRedDot(communityId: communityId)
    }
    
    static func clearUnreadCount(communityId: String, channelId: String, time: Int64) -> Bool {
        return Self.manager.unreadCountHandler.clearUnreadCount(communityId: communityId, channelId: channelId, time: time)
    }
    
    static func fetchFirstUnreadMessage(communityId: String, channelId: String) -> RCMessage? {
        return self.manager.unreadCountHandler.fetchFirstUnreadMessage(communityId: communityId, channelId: channelId)
    }
}
