//
//  RCSCLoginApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/30.
//

import Foundation

public struct RCSCUserModel: Codable {
    public let userId: String
    public let userName: String
    public let portrait: String?
    public var imToken: String
    public let authorization: String
    public let type: Int
    public var sex: Int
}

public struct RCSCLoginApi: RCSCApi {
    
    public typealias T = RCSCUserModel

    public var path: String {
        return "/user/login"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    let phone: String
    
    public init(phone: String) {
        self.phone = phone
    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: [
            "mobile": phone,
            "verifyCode":"666666",
            "deviceId": UIDevice.current.identifierForVendor!.uuidString,
            "platform": "mobile",
            "region": "+86"
        ].compactMapValues { $0 })
    }
}
