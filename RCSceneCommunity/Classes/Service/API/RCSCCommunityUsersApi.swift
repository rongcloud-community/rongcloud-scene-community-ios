//
//  RCSCCommunityUsersApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/10.
//

import Foundation

//查询类型,0:在线和离线全部,1:在线,2:离线,3:封禁,4:禁言
enum RCSCCommunityUserType: Int {
    case all = 0
    case online = 1
    case offline = 2
    case ban = 3
    case mute = 4
}

struct RCSCCommunityUsersApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/user/page"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityUid: String
    private let pageNum: Int
    private let pageSize: Int
    private let selectType: RCSCCommunityUserType
    
    init(communityUid: String, pageNum: Int, pageSize: Int, selectType: RCSCCommunityUserType) {
        self.communityUid = communityUid
        self.pageNum = pageNum
        self.pageSize = pageSize
        self.selectType = selectType
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":self.communityUid, "selectType":self.selectType.rawValue, "nickName":"", "pageNum":self.pageNum, "pageSize":self.pageSize])
    }
}
