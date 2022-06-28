//
//  RCSCResignOutApi.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/16.
//

import Foundation

public struct RCSCResignOutApi: RCSCApi {
    
    public typealias T = RCSCEmptyData

    public var path: String {
        return "/user/resign"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }

//    public init() {
//    }
    
    public func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: [:])
    }
}
