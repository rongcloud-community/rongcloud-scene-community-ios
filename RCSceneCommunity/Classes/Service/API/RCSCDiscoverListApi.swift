//
//  RCSCDiscoverListApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation

struct RCSCDiscoverListData: Codable {
    let records: [RCSCDiscoverListRecord]
    let total, size, current: Int
    let searchCount: Bool
    let pages: Int
}

struct RCSCDiscoverListRecord: Codable {
    let communityUid, name: String
    let portrait: String
    let personCount: Int
    let remark: String
    let coverUrl: String
}


struct RCSCDiscoverListApi: RCSCApi {
    
    typealias T = RCSCDiscoverListData

    var path: String {
        return "/mic/community/page"
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
