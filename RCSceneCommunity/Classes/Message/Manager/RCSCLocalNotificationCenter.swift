//
//  RCSCLocalNotificationCenter.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/6/14.
//

import RongCloudOpenSource



class RCSCLocalNotificationCenter {
    static func postNotification(message: RCMessage) {
        guard RCIMClient.shared().sdkRunningMode == .background,
              !RCKitConfig.default().message.disableMessageNotificaiton
        else { return }
        RCMessageNotificationHelper.checkNotifyAbility(with: message) { show in
            if (show) {
                self._postNotification(message: message)
            }
        }
    }
    
    private static func _postNotification(message: RCMessage) {
        guard let messagePushConfig = message.messagePushConfig else { return }
        
        let title = messagePushConfig.pushTitle ?? ""
        var content = messagePushConfig.pushContent ?? ""
        var unNotificationContent = UNMutableNotificationContent()
        unNotificationContent.title = title
        unNotificationContent.body = content
        unNotificationContent.sound = UNNotificationSound.default
        
        let identifier = message.messageUId ?? ""
        
        let request = UNNotificationRequest(identifier: identifier, content: unNotificationContent, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            debugPrint("add local notification failed error \(error)")
        }
        
    }
}
