//
//  RCSCCommunityUpdateInfoApi.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/9.
//

import Foundation

let RCSCParamNoticeTypeKey = "noticeType"

//社区信息更新
struct RCSCCommunityUpdateInfoApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/update"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private var param: Dictionary<String, Any>
    
    init(communityId: String, param: Dictionary<String, Any>) {
        self.param = param
        self.param["uid"] = communityId
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: self.param)
    }
}
