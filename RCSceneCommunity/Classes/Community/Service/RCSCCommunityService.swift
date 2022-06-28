//
//  RCSCCommunityService.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/11.
//

import UIKit
import SVProgressHUD

class RCSCCommunityService: RCSCBaseService {
    
    static let service = RCSCCommunityService()
    
    private override init() {
        super.init()
    }
}

//MARK: Data Source

protocol RCSCCommunityDataSourceDelegate: NSObjectProtocol {
    func createCommunitySuccess()
    func updateCommunityList(list: Array<RCSCCommunityListRecord>?)
    func updateCommunityDetail(detail: RCSCCommunityDetailData?)
//    func updateCommunityInfoSuccess()
    func updateCommunityInfo(_ isSuccess: Bool)
    func saveCommunityDetailSuccess()
    func saveCommunityUserInfoSuccess(params: Dictionary<String, Any>)
    func createGroupSuccess()
    func createChannelSuccess()
    func deleteCommunitySuccess(communityId: String)
    func markMessageSuccess()
    func deleteMarkMessageSuccess(_ markMessage: RCSCMarkMessage)
    func fetchUsersInfoSuccess(model: RCSCCommunityUserListModel, pageNum: Int, userType: RCSCCommunityUserType)
    func joinCommunitySuccess()
}

extension RCSCCommunityDataSourceDelegate {
    func createCommunitySuccess() {}
    func updateCommunityList(list: Array<RCSCCommunityListRecord>?) {}
    func updateCommunityDetail(detail: RCSCCommunityDetailData?){}
//    func updateCommunityInfoSuccess(){}
    func updateCommunityInfo(_ isSuccess: Bool){}
    func saveCommunityDetailSuccess() {}
    func saveCommunityUserInfoSuccess(params: Dictionary<String, Any>) {}
    func createGroupSuccess() {}
    func createChannelSuccess() {}
    func deleteCommunitySuccess(communityId: String) {}
    func markMessageSuccess() {}
    func deleteMarkMessageSuccess(_ markMessage: RCSCMarkMessage) {}
    func fetchUsersInfoSuccess(model: RCSCCommunityUserListModel, pageNum: Int, userType: RCSCCommunityUserType) {}
    func joinCommunitySuccess() {}
}

extension RCSCCommunityService {
    func createCommunity(name: String, avatar: String) {
        RCSCCommunityCreateApi(name: name, portrait: avatar).create().success { _ in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.createCommunitySuccess()
            }
        }
    }
    func updateCommunity(communityId: String,param: Dictionary<String, Any>){
        RCSCCommunityUpdateInfoApi(communityId: communityId, param: param).fetch().success { _ in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.updateCommunityInfo(true)
            }
        }
    }
    
    func fetchCommunityList() {
        RCSCCommunityListApi(pageNum: 1, pageSize: 1000).fetch().success { object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.updateCommunityList(list: object?.records)
            }
        }
    }
    
    func fetchDetail(communityId: String) {
        RCSCCommunityDetailApi(communityId: communityId).fetch().success { object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.updateCommunityDetail(detail: object)
            }
        }
    }
    
    func saveCommunityDetail(communityDetailDictionary: Dictionary<String, Any>, updateType: RCSCCommunityEditDetailType) {
        RCSCCommunityEditDetailApi(communityData: communityDetailDictionary, updateType: updateType).fetch().success {object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.saveCommunityDetailSuccess()
            }
        }
    }
    
   
    
    func saveCommunityUser(communityId: String, userId: String, param: Dictionary<String, Any>) {
        RCSCCommunityEditUserApi(communityId: communityId, userId: userId, param: param).fetch().success { object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.saveCommunityUserInfoSuccess(params: param)
            }
        }
    }
    
    func createGroup(communityId: String, name: String) {
        RCSCGroupCreateApi(communityId: communityId, name: name).create().success { object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.saveCommunityUserInfoSuccess(params:[:])
            }
        }
    }
    
    func createChannel(communityId: String, groupId: String, name: String) {
        RCSCChannelCreateApi(communityId: communityId, groupId: groupId, name: name).create().success { object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.createChannelSuccess()
                SVProgressHUD.showSuccess(withStatus: "频道创建成功")
            }
        }
    }
    
    
    func deleteCommunity(communityId: String) {
        RCSCCommunityDeleteApi(communityId: communityId).delete().success { _ in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.deleteCommunitySuccess(communityId: communityId)
            }
        }
    }
    
    func markMessage(channelId: String, messageUid: String) {
        RCSCCommunityMarkApi(channelUid: channelId, messageUid: messageUid).mark().success { _ in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.markMessageSuccess()
                SVProgressHUD.showSuccess(withStatus: "标注消息成功")
            }
        }
    }
    

    func deleteMarkMessage(markMessage: RCSCMarkMessage) {
        RCSCCommunityDeleteMarkApi(messageUid: markMessage.messageUid).deleteMark().success { object in
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.deleteMarkMessageSuccess(markMessage)
                SVProgressHUD.showSuccess(withStatus: "删除标注消息成功")
            }
        }
    }
    
    func fetchCommunityUsers(communityUid: String, selectType: RCSCCommunityUserType, pageNum: Int, pageSize: Int, nickName: String? = nil) {
        RCSCCommunityUserListApi(communityUid: communityUid, selectType: selectType, pageNum: pageNum, pageSize: pageSize, nickName: nickName).fetch().success { object in
            guard let object = object else {
                SVProgressHUD.showError(withStatus: "获取用户数据失败")
                return
            }
            self.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.fetchUsersInfoSuccess(model: object, pageNum: pageNum, userType: selectType)
            }
        }
    }
    
    func joinCommunity(communityId: String) {
        RCSCCommunityJoinApi(communityId: communityId).fetch().success {[weak self] _ in
            self?.execute(protocol: RCSCCommunityDataSourceDelegate.self) { listener in
                listener.joinCommunitySuccess()
            }
        }
    }
}

