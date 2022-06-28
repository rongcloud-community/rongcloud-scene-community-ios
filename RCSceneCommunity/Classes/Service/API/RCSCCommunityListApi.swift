//
//  RCSCCommunityListApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/30.
//

import Foundation

struct RCSCCommunityListModel: Codable {
    let records: [RCSCCommunityListRecord]
    let total: Int
    let size: Int
    let current: Int
    let searchCount: Bool?
    let pages: Int
}

struct RCSCCommunityListRecord: Codable {
    let communityUid: String
    let name: String
    let portrait: String
    let remark: String
}


struct RCSCCommunityListApi: RCSCApi {
    
    typealias T = RCSCCommunityListModel

    var path: String {
        return "/mic/community/user/pageCommunity"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let pageNum: Int
    private let pageSize: Int
    
    init(pageNum: Int, pageSize: Int) {
        self.pageNum = pageNum
        self.pageSize = pageSize
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["pageNum":self.pageNum, "pageSize":self.pageSize])
    }
}
