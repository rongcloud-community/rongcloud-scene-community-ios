//
//  RCSCCommunityDetailApi.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/2.
//

import Foundation

enum RCSCCommunityNotifySettingType: Int, Codable {
    case all = 0
    case at = 1
    case never = 2
    case custom = 3 //占位
}

enum RCSCCommunityNeedAuditType: Int, Codable {
    case free = 0
    case need = 1
}

enum RCSCCommunityUserStatus: Int, Codable {
    case join = 0
    case check = 1
    case reject = 2
    case joined = 3
    case quite = 4
    case kick = 5
}

struct RCSCCommunityDetailData: Equatable,Codable, ConvertAble{
    let id: Int
    let uid: String
    let creator: String
    var name: String
    var portrait: String
    var coverUrl: String
    var remark: String
    var needAudit: RCSCCommunityNeedAuditType
    var noticeType: RCSCCommunityNotifySettingType
    var joinChannelUid: String
    var msgChannelUid: String
    let personCount: Int
    var communityUser: RCSCCommunityDetailUser
    var groupList: [RCSCCommunityDetailGroup]
    var channelList: [RCSCCommunityDetailChannel]
    
    func channelName(channelId: String) -> String {
        var channelName = ""
        for groupList in groupList {
            for channel in groupList.channelList {
                if channel.uid == channelId {
                    channelName = channel.name
                }
            }
        }
        return channelName
    }
}

struct RCSCCommunityDetailUser: Equatable, Codable {
    var auditStatus: RCSCCommunityUserStatus
    var noticeType: RCSCCommunityNotifySettingType
    var shutUp: Int?
    var nickName: String?
}


struct RCSCCommunityDetailGroup: Equatable,Codable {
    let uid: String
    var name: String
    let sort: Int
    var on: Bool?
    var channelList: [RCSCCommunityDetailChannel]
}

// MARK: - ChannelList
struct RCSCCommunityDetailChannel:Equatable, Codable {
    let uid: String
    var name: String
    let sort: Int
    let noticeType: RCSCCommunityNotifySettingType
    let groupUid: String
}

struct RCSCCommunityDetailApi: RCSCApi {
    
    typealias T = RCSCCommunityDetailData

    var path: String {
        return "/mic/community/detail/\(communityId)"
    }
    
    var method: RCSCHTTPMethod {
        return .post
    }
    
    var responseClass: T.Type {
        return T.self
    }
    
    private let communityId: String
    
    init(communityId: String) {
        self.communityId = communityId
    }
    
    func fetch() -> RCSCHTTPTask<T> {
        return fetch(parameters: ["communityUid":communityId])
    }
}
