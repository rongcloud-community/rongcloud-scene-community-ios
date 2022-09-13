//
//  RCSCChannelMessage.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/20.
//

import UIKit

public enum RCSCUserInfoUpdateMessageType: Int, Codable {
    case avatar = 1
    case name = 2
}

public struct RCSCUserInfoUpdateContent: Codable {
    public let userId: String?
    public let nickName: String?
    public let portrait: String?
    public let type: RCSCUserInfoUpdateMessageType?
}

class RCSCUserInfoUpdateMessage: RCMessageContent {
    public var content: RCSCUserInfoUpdateContent?
  
    public override func encode() -> Data! {
      guard let content = content else { return Data() }
      do {
          let data = try JSONEncoder().encode(content)
          return data
      } catch {
          fatalError("RCSCUserInfoUpdateMessage encode failed")
      }
  }
  
    public override func decode(with data: Data!) {
        do {
            content = try JSONDecoder().decode(RCSCUserInfoUpdateContent.self, from: data)
        } catch {
            fatalError("RCSCUserInfoUpdateMessage decode failed: \(error.localizedDescription)")
        }
    }
  
    public override class func getObjectName() -> String { "RCMic:UserUpdate" }
    public override class func persistentFlag() -> RCMessagePersistent { .MessagePersistent_NONE }
  
    public override func getSearchableWords() -> [String]! {
      return []
    }
}
