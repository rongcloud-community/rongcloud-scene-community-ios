//
//  RCSCMarkMessageDetail.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/6/23.
//

import Foundation

public struct RCSCMarkMessageDetailModel: Codable {
    public let channelUid: String
    public let creator: String
    public let messageUid: String?
    public let uid: String?
}

public struct RCSCMarkMessageDetailApi: RCSCApi {
    
    public typealias T = RCSCMarkMessageDetailModel

    public var path: String {
        return "/mic/channel/message/detail/\(messageUid)"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    let messageUid: String
    
    public init(messageUid: String) {
        self.messageUid = messageUid
    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["messageUid":messageUid])
    }
}
