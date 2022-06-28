//
//  RCSCCommunityEditUserApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/19.
//

import Foundation

let kRCSCCommunityUserStatusKey = "status"
let kRCSCCommunityUserFreezeKey = "freezeFlag"
let kRCSCCommunityUserMuteKey = "shutUp"

//社区用户设置信息更新
struct RCSCCommunityEditUserApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/user/update"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private var param: Dictionary<String, Any>
    
    init(communityId: String, userId: String, param: Dictionary<String, Any>) {
        self.param = param
        self.param["communityUid"] = communityId
        self.param["userUid"] = userId
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: self.param)
    }
}

/*
 "communityUid": 社区ID
 "freezeFlag": 是否被封禁 0没有 1封禁
 "nickName": 昵称
 "noticeType": 用户群通知设置,0:所有消息都接收,1:被@时通知，2:从不通知
 "shutUp": 0, 是否被禁言0:没有,1:禁言
 "status": 0, 2:审核未通过,3:审核通过,4:退出，5：被踢出
 "userUid": 用户ID
 https://rcrtc-api.rongcloud.net/doc.html#/scene/%E7%A4%BE%E5%8C%BA%E7%94%A8%E6%88%B7%E7%9B%B8%E5%85%B3/updateUsingPOST
 */
