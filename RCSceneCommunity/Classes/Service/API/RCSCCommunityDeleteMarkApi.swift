//
//  RCSCCommunityDeleteMarkApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/9.
//

import Foundation

struct RCSCCommunityDeleteMarkApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/channel/message/delete/\(messageUid)"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let messageUid: String
    
    init( messageUid: String) {
        self.messageUid = messageUid
    }
    
    func deleteMark() -> RCSCHTTPTask<T> {
        return fetch(parameters: nil)
    }
}
