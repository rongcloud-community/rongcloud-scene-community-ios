//
//  RCSCApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/28.
//

import Foundation

let kHost = RCSCConfig.serviceHost

public protocol RCSCApi {
    associatedtype T: Codable
    var path: String { get }
    var method: RCSCHTTPMethod { get }
    var responseClass: T.Type { get }
}

public extension RCSCApi {
    static func defaultHeaders() -> [String : String]? {
        var header = [String: String]()
        if let authorization = RCSCUser.RCSCGetUser()?.authorization {
            header["Authorization"] = authorization
        }
        header["BusinessToken"] = RCSCConfig.businessToken
        return header
    }
    
    func fetch(parameters: [String : Any]?, _ headers: [String: String]? = nil) -> RCSCHTTPTask<T> {
        switch method {
            case .get:
            return RCSCNetwork.network.get(url: kHost + path, parameters: parameters, headers: headers ?? Self.defaultHeaders(), type: responseClass)
            default:
            return RCSCNetwork.network.post(url: kHost + path, parameters: parameters, headers: headers ?? Self.defaultHeaders(), type: responseClass)
        }
    }
    
    func upload(data: Data) -> RCSCHTTPTask<T> {
        let data = RCSCMultipartFormData(data: data, name: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
        return RCSCNetwork.network.upload(url: kHost + path, method: .post, parameters: nil, datas: [data], headers: Self.defaultHeaders(), type: responseClass)
    }
}
