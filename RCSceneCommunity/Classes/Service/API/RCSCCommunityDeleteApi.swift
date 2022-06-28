//
//  RCSCCommunityDeleteApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/22.
//

import Foundation

struct RCSCCommunityDeleteApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/delete/\(communityId)"
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
    
    func delete() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":communityId])
    }
}
