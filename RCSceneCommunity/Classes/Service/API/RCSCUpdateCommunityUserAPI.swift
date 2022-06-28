//
//  RCSCUpdateCommunityUserAPI.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/5.
//

import Foundation


public struct RCSCUpdateCommunityUserAPI: RCSCApi {
    
    public  typealias T = RCSCEmptyData

    public var path: String {
        return "/mic/community/user/update"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    let communityUid: String
    let userUid: String
    let status:Int
    public init(communityUid: String,userUid: String,status:Int) {
        self.communityUid = communityUid
        self.userUid = userUid
        self.status = status
    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: [
   
            "communityUid":communityUid,
            "userUid": userUid,
            "status": status
        ].compactMapValues { $0 })
    }
}
