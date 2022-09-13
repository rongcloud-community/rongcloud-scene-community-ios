//
//  RCSCSystemMessageContent.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/4.
//

import Foundation

//"type":0代表申请加入社区、1代表加入社区后通知消息、2代表退出社区的通知消息，3代表被踢出社区的通知消息,4代表被禁言，5代表解除禁言 6代表被拒绝加入 7代表解散社区


public enum RCSCSystemMessageType: Int, Codable {
    case requestJoin = 0
    case joined = 1
    case quit = 2
    case kickOut = 3
    case mute = 4
    case release = 5
    case reject = 6
    case dissolve = 7
}

struct RCSCSystemMessageContent: Codable {
   ///用户id
  let fromUserId: String?
  /// 社区id
  let communityUid: String?
  /// 消息体
  let message: String?
  /// 消息类型 0代表申请加入社区、1代表加入社区后通知消息、2代表退出社区的通知消息，3代表被踢出社区的通知消息
  let type: RCSCSystemMessageType?
}

class RCSCSystemMessage:RCMessageContent{
    var content:RCSCSystemMessageContent?
    override func encode() -> Data! {
        guard let content = content else { return Data() }
        do {
            let data = try JSONEncoder().encode(content)
            return data
        } catch {
            fatalError("RCSCSystemMessage encode failed")
        }
    }
    
      override func decode(with data: Data!) {
          do {
              content = try JSONDecoder().decode(RCSCSystemMessageContent.self, from: data)
          } catch {
              fatalError("RCSCSystemMessage decode failed: \(error.localizedDescription)")
          }
      }
    
    override class func getObjectName() -> String { "RCMic:CommunitySysNotice" }
    override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_ISCOUNTED }
    
    override func getSearchableWords() -> [String]! {
        return []
    }
}
