//
//  RCSCCommunityMarkApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/6.
//

import Foundation


struct RCSCCommunityMarkModel: Codable {
    let records: [RCSCCommunityMarkMessage]
    let total, size, current: Int
    let searchCount: Bool
    let pages: Int
}

// MARK: - Record
struct RCSCCommunityMarkMessage: Codable {
    let uid, channelUid, messageUid: String
}

struct RCSCCommunityMarkApi: RCSCApi {
    
    typealias T = RCSCCommunityMarkModel

    var path: String {
        return "/mic/channel/message/save"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let channelUid: String
    private let messageUid: String
    
    init(channelUid: String, messageUid: String) {
        self.channelUid = channelUid
        self.messageUid = messageUid
    }
    
    func mark() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["channelUid":self.channelUid, "messageUid":self.messageUid])
    }
}
