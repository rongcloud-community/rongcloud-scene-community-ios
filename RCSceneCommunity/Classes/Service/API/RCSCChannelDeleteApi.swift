//
//  RCSCChannelDeleteApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/6/7.
//

struct RCSCChannelDeleteApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/channel/delete/\(channelUid)"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let channelUid: String
    
    init(channelUid: String) {
        self.channelUid = channelUid
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: nil)
    }
}
