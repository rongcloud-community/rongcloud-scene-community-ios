//
//  RCSCChannelCreateApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/11.
//

import Foundation

struct RCSCChannelCreateApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/channel/save"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityId: String
    private let groupId: String
    private let name: String

    init(communityId: String, groupId: String, name: String) {
        self.communityId = communityId
        self.groupId = groupId
        self.name = name
    }
    
    func create() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":communityId, "groupUid":groupId, "name":name])
    }
}
