//
//  RCSCCommunityEditApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/19.
//

import Foundation

enum RCSCCommunityEditDetailType: Int {
    case group = 1
    case channel = 2
    case info = 3
}

struct RCSCCommunityEditDetailApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/saveAll"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private var communityData: Dictionary<String, Any>
    
    init(communityData: Dictionary<String, Any>, updateType: RCSCCommunityEditDetailType) {
        self.communityData = communityData
        self.communityData["updateType"] = updateType.rawValue
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: self.communityData)
    }
}
