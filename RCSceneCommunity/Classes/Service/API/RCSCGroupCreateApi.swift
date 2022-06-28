//
//  RCSCGroupCreateApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/19.
//

import Foundation

struct RCSCGroupCreateApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/group/save"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityId: String
    private let name: String

    init(communityId: String, name: String) {
        self.communityId = communityId
        self.name = name
    }
    
    func create() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":communityId, "name":name])
    }
}
