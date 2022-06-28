//
//  RCSCChannelDetailApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/19.
//

struct RCSCChannelDetailData: Codable {
    let name, remark, uid: String
}

struct RCSCChannelDetailApi: RCSCApi {
    
    typealias T = RCSCChannelDetailData

    var path: String {
        return "/mic/channel/detail/\(channelId)"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let channelId: String
    
    init(channelId: String) {
        self.channelId = channelId
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: nil)
    }
}
