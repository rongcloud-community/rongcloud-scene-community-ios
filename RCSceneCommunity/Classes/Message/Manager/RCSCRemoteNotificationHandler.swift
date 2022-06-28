//
//  RCSCNotificationSettingHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/6/1.
//


class RCSCRemoteNotificationHandler: NSObject {
    
    let channel = RCChannelClient.sharedChannelManager()!
    
    //MARK: 超级群默认通知
    func setCommunityDefaultNotificationType(communityId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        channel.setUltraGroupConversationDefaultNotificationLevel(communityId, level: level, success: success, error: error)
    }
    
    func getCommunityDefaultNotificationType(communityId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        channel.getUltraGroupConversationDefaultNotificationLevel(communityId, success: success, error: error)
    }
    
    func setChannelDefaultNotificationType(communityId: String, channelId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        channel.setUltraGroupConversationChannelDefaultNotificationLevel(communityId, channelId: channelId, level: level, success: success, error: error)
    }
    
    func getChannelDefaultNotificationType(communityId: String, channelId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void))  {
        channel.getUltraGroupConversationChannelDefaultNotificationLevel(communityId, channelId: channelId, success: success, error: error)
    }
    
    //MARK: 用户设置
    func setCommunityNotificationType(communityId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        channel.setConversationNotificationLevel(.ConversationType_ULTRAGROUP, targetId: communityId, level: level, success: success, error: error)
    }
    
    func getCommunityNotificationType(communityId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        channel.getConversationNotificationLevel(.ConversationType_ULTRAGROUP, targetId: communityId, success: success, error: error)
    }
    
    func setChannelNotificationType(communityId: String, channelId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        channel.setConversationChannelNotificationLevel(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, level: level, success: success, error: error)
    }
    
    func getChannelNotificationType(communityId: String, channelId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void))  {
        channel.getConversationChannelNotificationLevel(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, success: success, error: error)
    }
}

extension RCSCConversationMessageManager {
    //MARK: 超级群默认通知
    static func setCommunityDefaultNotificationType(communityId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        Self.manager.remoteNotificationHandler.setCommunityDefaultNotificationType(communityId: communityId, level: level, success: success, error: error)
    }
    
    static func getCommunityDefaultNotificationType(communityId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        Self.manager.remoteNotificationHandler.getCommunityDefaultNotificationType(communityId: communityId, success: success, error: error)
    }
    
    static func setChannelDefaultNotificationType(communityId: String, channelId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        Self.manager.remoteNotificationHandler.setChannelDefaultNotificationType(communityId: communityId, channelId: channelId, level: level, success: success, error: error)
    }
    
    static func getChannelDefaultNotificationType(communityId: String, channelId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void))  {
        Self.manager.remoteNotificationHandler.getChannelDefaultNotificationType(communityId: communityId, channelId: channelId, success: success, error: error)
    }
    
    //MARK: 用户设置
    
    static func setCommunityNotificationType(communityId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        Self.manager.remoteNotificationHandler.setCommunityNotificationType(communityId: communityId, level: level, success: success, error: error)
    }
    
    static func getCommunityNotificationType(communityId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        Self.manager.remoteNotificationHandler.getCommunityNotificationType(communityId: communityId, success: success, error: error)
    }
    
    static func setChannelNotificationType(communityId: String, channelId: String, level: RCPushNotificationLevel, success: @escaping (() -> Void), error: @escaping ((RCErrorCode) -> Void)) {
        Self.manager.remoteNotificationHandler.setChannelNotificationType(communityId: communityId, channelId: channelId, level: level, success: success, error: error)
    }
    
    static func getChannelNotificationType(communityId: String, channelId: String, success: @escaping ((RCPushNotificationLevel) -> Void), error: @escaping ((RCErrorCode) -> Void))  {
        Self.manager.remoteNotificationHandler.getChannelNotificationType(communityId: communityId, channelId: channelId, success: success, error: error)
    }
    
    static let semaphore = DispatchSemaphore(value: 1)
    
    static func initializeNotificationSettingWithServerData(communityId: String) {
        RCSCCommunityDetailApi(communityId: communityId).fetch().success { object in
            guard let object = object else { return }
            let level: RCPushNotificationLevel = object.noticeType == .all ? .allMessage : .mention
            DispatchQueue.global().async {
                semaphore.wait()
                RCSCConversationMessageManager.setCommunityNotificationType(communityId: object.uid, level: level) {
                    debugPrint("community id: \(object.uid) set default notification type success")
                    semaphore.signal()
                } error: { code in
                    debugPrint("community id: \(object.uid) set default notification type failed code: \(code.rawValue)")
                    semaphore.signal()
                }

                for group in object.groupList {
                    for channel in group.channelList {
                        semaphore.wait()
                        RCSCConversationMessageManager.setChannelNotificationType(communityId: object.uid, channelId: channel.uid, level: level) {
                            debugPrint("channel id: \(channel.uid) set default notification type success")
                            semaphore.signal()
                        } error: { code in
                            debugPrint("channel id: \(channel.uid) set default notification type failed code: \(code.rawValue)")
                            semaphore.signal()
                        }
                    }
                }
            }
        }
    }
    
    //设置
    static func setChildChannelNotificationSetting(communityDetail: RCSCCommunityDetailData, level: RCPushNotificationLevel) {
        for group in communityDetail.groupList {
            for channel in group.channelList {
                DispatchQueue.global().async {
                    semaphore.wait()
                    RCSCConversationMessageManager.setChannelNotificationType(communityId: communityDetail.uid, channelId: channel.uid, level: level) {
                        debugPrint("channel id: \(channel.uid) set default notification type success")
                        semaphore.signal()
                    } error: { code in
                        debugPrint("channel id: \(channel.uid) set default notification type failed code: \(code.rawValue)")
                        semaphore.signal()
                    }
                }
            }
        }
    }
}
