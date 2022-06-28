//
//  RCSCChannelNotifySettingApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/26.
//

enum RCSCChannelNotifySettingNoticeType: Int {
    case followCommunity = -1
    case all = 0
    case at = 1
    case never = 2
}

struct RCSCChannelNotifySettingApi: RCSCApi {
    
    typealias T = RCSCEmptyData

    var path: String {
        return "/mic/community/user/update/channel"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityId: String
    private let channelId: String
    private let noticeType: RCSCChannelNotifySettingNoticeType
    
    init(communityId: String, channelId: String, noticeType: RCSCChannelNotifySettingNoticeType) {
        self.communityId = communityId
        self.channelId = channelId
        self.noticeType = noticeType
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["channelUid": self.channelId, "communityUid": self.communityId, "noticeType": self.noticeType.rawValue])
    }
}
