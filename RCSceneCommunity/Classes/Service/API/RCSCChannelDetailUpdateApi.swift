//
//  RCSCChannelDetailUpdateApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/19.
//


struct RCSCChannelDetailUpdateApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/channel/update"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private var param: Dictionary<String, String>
    
    init(channelId: String, param: Dictionary<String, String>) {
        self.param = param
        self.param["uid"] = channelId
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: param)
    }
}

