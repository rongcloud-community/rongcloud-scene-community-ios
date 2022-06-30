//
//  RCSCCommunityManager.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/11.
//

import Foundation
import SVProgressHUD

class RCSCCommunityManager: NSObject {
    
    static let manager = RCSCCommunityManager()
    
    var detailData: RCSCCommunityDetailData?
    
    var currentDetail: RCSCCommunityDetailData {
        get {
            if let detailData = detailData {
                return detailData
            } else {
                assert(false, "当前社区详情信息为空")
                return detailData!
            }
        }
        set {
            detailData = newValue
        }
    }
    
    var service: RCSCCommunityService {
        get {
            return RCSCCommunityService.service
        }
    }
    
    var needJumpToDefaultChannel = false
    
    weak var currentConversationViewController: RCSCConversationViewController?
    
    private override init() {
        super.init()
        registerListener(listener: self)
    }
    
    func registerListener(listener: AnyObject) {
        service.registerListener(listener: listener)
    }
    
    static func initialized() {
        let _ = self.manager
    }
    
    func createCommunity(name: String, avatar: String) {
        service.createCommunity(name: name, avatar: avatar)
    }
    func updateCommunity(communityId: String,param: Dictionary<String, Any>) {
        service.updateCommunity(communityId: communityId, param: param)
    }
   
    func createChannel(communityId: String, groupId: String, channelName: String) {
        service.createChannel(communityId: communityId, groupId: groupId, name: channelName)
    }
    
    func fetchDetail(communityId: String) {
        service.fetchDetail(communityId: communityId)
    }
    
    func fetchCommunityList() {
        service.fetchCommunityList()
    }
    
    func saveCommunityDetail(communityDetailDictionary: Dictionary<String, Any>, updateType: RCSCCommunityEditDetailType) {
        service.saveCommunityDetail(communityDetailDictionary: communityDetailDictionary, updateType: updateType)
    }
    
    func saveCommunityUser(param: Dictionary<String, Any>, userId: String) {
        service.saveCommunityUser(communityId: currentDetail.uid, userId: userId, param: param)
    }
    
    func createGroup(name: String) {
        service.createGroup(communityId: currentDetail.uid, name: name)
    }
    
    func deleteCommunity() {
        service.deleteCommunity(communityId: currentDetail.uid)
    }
}

extension RCSCCommunityManager: RCSCCommunityDataSourceDelegate {
    func updateCommunityDetail(detail: RCSCCommunityDetailData?) {
        if let detail = detail {
            detailData = detail
        }
    }
    
    func saveCommunityDetailSuccess() {
        service.fetchDetail(communityId: self.currentDetail.uid)
    }
    
    func saveCommunityUserInfoSuccess(params: Dictionary<String, Any>) {
        //当钱操作为退出操作时，不刷新社区详情
        if !params.keys.contains(kRCSCCommunityUserStatusKey) {
            service.fetchDetail(communityId: self.currentDetail.uid)
        }
    }
    
    func createGroupSuccess() {
        service.fetchDetail(communityId: self.currentDetail.uid)
    }
    
    func deleteCommunitySuccess(communityId: String) {
        //im信令统一刷新
        //service.fetchCommunityList()
        SVProgressHUD.showInfo(withStatus: "解散社区成功")
    }
}
