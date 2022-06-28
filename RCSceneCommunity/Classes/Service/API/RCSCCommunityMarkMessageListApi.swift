//
//  RCSCCommunityMarkMessageListApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/10.
//

import Foundation

struct RCSCMarkMessageModel: Codable {
    let records: [RCSCMarkMessage]
    let total, size, current: Int
    let searchCount: Bool
    let pages: Int
}

struct RCSCMarkMessage: Codable {
    let uid, channelUid, messageUid: String
}

struct RCSCCommunityMarkMessageListApi: RCSCApi {
    
    typealias T = RCSCMarkMessageModel

    var path: String {
        return "/mic/channel/message/page"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let channelUid: String
    private let pageNum: Int
    private let pageSize: Int
    
    init(channelUid: String, pageNum: Int, pageSize: Int) {
        self.channelUid = channelUid
        self.pageNum = pageNum
        self.pageSize = pageSize
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["channelUid":self.channelUid, "pageNum":self.pageNum, "pageSize":self.pageSize])
    }
}
