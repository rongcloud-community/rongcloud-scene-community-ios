//
//  RCSCCommunityApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/29.
//

import Foundation

struct RCSCCommunityCreateApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/save"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let name: String
    private let portrait: String
    
    init(name: String, portrait: String) {
        self.name = name
        self.portrait = portrait
    }
    
    func create() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["name":name, "portrait":portrait])
    }
}
