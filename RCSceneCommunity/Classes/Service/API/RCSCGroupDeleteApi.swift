//
//  RCSCGroupDeleteApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/6/7.
//

struct RCSCGroupDeleteApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/group/delete/\(groupUid)"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let groupUid: String
    
    init(groupUid: String) {
        self.groupUid = groupUid
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: nil)
    }
}
