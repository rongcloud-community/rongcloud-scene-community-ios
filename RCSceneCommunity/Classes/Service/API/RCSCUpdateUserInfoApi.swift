//
//  RCSCUpdateUserInfoApi.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/13.
//

import Foundation
/*
 {
   "code" : 10000,
   "data" : {
     "id" : 9021,
     "uid" : "74f93963-87ff-4eef-959d-50b74caeb557",
     "name" : "用户6891",
     "portrait" : "",
     "mobile" : "15110116891",
     "type" : 1,
     "deviceId" : "5CD5C007-F5F0-4B6F-A8A4-3A7988504BC8",
     "createDt" : 1652372091000,
     "updateDt" : 1652372091000,
     "sex" : 1,
     "businessId" : "kwaRD0DET_smGxiBiWaGtU"
   }
 }
 
 
 struct RCSCUserUPInfo {
     let id: String
     let uid: String
     let name: String
     let portrait: String?
     public let type: Int
     public var sex: Int
     
 }
 */


public struct RCSCUserUPInfo: Codable {
    public let name: String
    public let portrait: String?
    public let type: Int
    public var sex: Int
}
public struct RCSCUpdateUserInfoApi: RCSCApi {
    
    public typealias T = RCSCUserUPInfo

    public var path: String {
        return "/user/update"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    let userData: [String:Any]
    
    public init(userData: [String:Any]) {
        self.userData = userData
    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: userData)
    }
}
