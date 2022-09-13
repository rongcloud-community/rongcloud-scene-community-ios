//
//  RCSCChangeMessage.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/20.
//

import UIKit

public struct RCSCChangeContent: Codable {
    public let communityUid: String?
    public let fromUserId: String?
    public let message: String?
    public let channelUids: Array<String>?
}

class RCSCChangeMessage: RCMessageContent {
    public var content: RCSCChangeContent?
  
    public override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCSCChangeMessage encode failed")
      }
  }
  
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCSCChangeContent.self, from: data)
        } catch {
            fatalError("RCSCChangeMessage decode failed: \(error.localizedDescription)")
        }
    }
  
    public override class func getObjectName() -> String { "RCMic:CommunityChange" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
    public override func getSearchableWords() -> [String]! {
      return []
    }
}
