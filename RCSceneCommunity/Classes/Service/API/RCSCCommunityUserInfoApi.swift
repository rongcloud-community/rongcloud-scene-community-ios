//
//  RCSCCommunityNIckNameApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/18.
//


class RCSCCommunityUserInfo: Codable {
    var userUid, nickName, portrait: String
    var status: Int //用户社区状态 1:审核中,2:审核未通过,3:已进入，4:退出,5:被踢出
    init(userUid: String, nickName: String, portrait: String, status: Int) {
        self.nickName = nickName
        self.userUid = userUid
        self.portrait = portrait
        self.status = status
    }
}

struct RCSCCommunityUserInfoApi: RCSCApi {
    
    typealias T = RCSCCommunityUserInfo

    var path: String {
        return "/mic/community/user/info"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityUid: String
    private let userUid: String
    
    init(communityUid: String, userUid: String) {
        self.communityUid = communityUid
        self.userUid = userUid
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":communityUid, "userUid":userUid])
    }
}

