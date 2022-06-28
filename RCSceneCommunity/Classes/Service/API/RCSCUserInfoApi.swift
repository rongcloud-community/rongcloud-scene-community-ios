//
//  RCSCUserInfoApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/9.
//

import Foundation

public struct RCSCUserInfoModel: Codable {
    public let userId: String
    public let userName: String
    public let portrait: String?
    public let status: Int?
}

public struct RCSCUserInfoApi: RCSCApi {
    
    public typealias T = [RCSCUserInfoModel]

    public var path: String {
        return "/user/batch"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    let userIds: Array<String>
    
    public init(userIds: Array<String>) {
        self.userIds = userIds
    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["userIds":userIds])
    }
}
