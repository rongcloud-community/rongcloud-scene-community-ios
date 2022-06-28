//
//  RCSCUploadApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/8.
//

import Foundation

public struct RCSCUploadApi: RCSCApi {
    
    public typealias T = String

    public var path: String {
        return "/file/upload"
    }
    
    public var method: RCSCHTTPMethod {
        return .post
    }
    
    public var responseClass: T.Type {
        return T.self
    }
    
    public func uploadImage(data: Data) -> RCSCHTTPTask<T> {
        return upload(data: data)
    }
}
