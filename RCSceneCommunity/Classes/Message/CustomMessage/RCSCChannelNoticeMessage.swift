//
//  RCSCChannelNoticeMessage.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/9.
//

import Foundation

//1代表加入消息，2代表标记消息，3代表被禁言，4代表解除禁言,5删除标记消息,6.主动退出社区
public enum RCSCChannelNoticeMessageType: Int, Codable {
    case join = 1
    case mark = 2
    case mute = 3
    case releaseMute = 4
    case deleteMark = 5
    case quit = 6
}

public struct RCSCChannelNoticeMessageContent: Codable {
    public let fromUserId: String?
    public let communityUid: String?
    public let channelUid: String?
    public let message: String?
    public let messageUid: String?
    public let type: RCSCChannelNoticeMessageType?
    init(fromUserId: String?, communityUid: String?, channelUid: String?, message: String?, messageUid: String?, type: RCSCChannelNoticeMessageType?) {
        self.channelUid = channelUid
        self.fromUserId = fromUserId
        self.communityUid = communityUid
        self.message = message
        self.messageUid = messageUid
        self.type = type
    }
}

public class RCSCChannelNoticeMessage: RCMessageContent {
    
    public var content: RCSCChannelNoticeMessageContent?
  
    public override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCSCChannelNoticeMessage encode failed")
      }
  }
  
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCSCChannelNoticeMessageContent.self, from: data)
        } catch {
            fatalError("RCSCChannelNoticeMessage decode failed: \(error.localizedDescription)")
        }
    }
  
    public override class func getObjectName() -> String! { "RCMic:ChannelNotice" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_ISCOUNTED }
  
    public override func getSearchableWords() -> [String]! {
      return []
    }
}
