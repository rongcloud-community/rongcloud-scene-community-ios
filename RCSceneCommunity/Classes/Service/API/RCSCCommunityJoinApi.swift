//
//  RCSCCommunityJoinApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation

struct RCSCCommunityJoinApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/user/join/\(communityId)"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityId: String
    
    init(communityId: String) {
        self.communityId = communityId
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":self.communityId])
    }
}
