//
//  RCSCDeleteMessage.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/20.
//

import UIKit

public struct RCSCDeleteContent: Codable {
    public let communityUid: String?
}

class RCSCDeleteMessage: RCMessageContent {
    public var content: RCSCDeleteContent?
  
    public override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCSCDeleteMessage encode failed")
      }
  }
  
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCSCDeleteContent.self, from: data)
        } catch {
            fatalError("RCSCDeleteMessage decode failed: \(error.localizedDescription)")
        }
    }
  
    public override class func getObjectName() -> String { "RCMic:CommunityDelete" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
    public override func getSearchableWords() -> [String]! {
      return []
    }
}
