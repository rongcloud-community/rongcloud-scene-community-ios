//
//  RCSCGetSysMsgUserInfoApi.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/5.
//

import Foundation

public struct RCSCSysMsgUserInfo: Codable {
    public let userId: String
    public let userName: String
    public let portrait: String?
    public let status: Int
}

public struct RCSCGetSysUserInfoApi: RCSCApi {
    
    public  typealias T = [RCSCSysMsgUserInfo]

    public var path: String {
        return "/user/batch"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    let userIds: [String]
    public init(_ userIds:[String]) {
        self.userIds = userIds
    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: [
   
            "userIds":userIds,
        ].compactMapValues { $0 })
    }
}
