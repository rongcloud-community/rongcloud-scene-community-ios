//
//  RCSCCommunityUserListApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/13.
//

import Foundation

struct RCSCCommunityUserListModel: Codable {
    let records: [RCSCCommunityUser]
    let total, size, current: Int
    let searchCount: Bool
    let pages: Int
}

// MARK: - Record
struct RCSCCommunityUser: Codable {
    var userUid, name, portrait: String
    var creatorFlag: Bool
    var shutUp, onlineStatus: Int
    var isMute: Bool {
        get {
            return shutUp == 1
        }
    }
}

struct RCSCCommunityUserListApi: RCSCApi {
    
    typealias T = RCSCCommunityUserListModel

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
    private let nickName: String?
    private let selectType: RCSCCommunityUserType
    private let pageNum: Int
    private let pageSize: Int
    
    init(communityUid: String, selectType: RCSCCommunityUserType, pageNum: Int, pageSize: Int, nickName: String?) {
        self.communityUid = communityUid
        self.selectType = selectType
        self.nickName = nickName
        self.pageNum = pageNum
        self.pageSize = pageSize
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        var param = Dictionary<String, Any>()
        param["communityUid"] = communityUid
        param["selectType"] = selectType.rawValue
        param["pageNum"] = pageNum
        param["pageSize"] = pageSize
        if let nickName = nickName, nickName.count > 0 {
            param["nickName"] = nickName
        }
        return fetch(parameters: param)
    }
}
