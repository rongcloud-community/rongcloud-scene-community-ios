//
//  RCSCChannelService.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/19.
//

import SVProgressHUD


class RCSCChannelService: RCSCBaseService {
    
    static let service = RCSCChannelService()
    
    private override init() {
        super.init()
    }
}

//MARK: Data Source

protocol RCSCChannelDataSourceDelegate: NSObjectProtocol {
    func fetchChannelDetailSuccess(detail: RCSCChannelDetailData)
}

extension RCSCChannelDataSourceDelegate {
    func fetchChannelDetailSuccess(detail: RCSCChannelDetailData) {}
}

extension RCSCChannelService {
    func fetchChannelDetail(channelId: String) {
        RCSCChannelDetailApi(channelId: channelId).fetch().success {[weak self] object in
            guard let object = object else {
                SVProgressHUD.showError(withStatus: "获取频道信息失败")
                return
            }
            self?.execute(protocol: RCSCChannelDataSourceDelegate.self) { listener in
                listener.fetchChannelDetailSuccess(detail: object)
            }
        }.failed { error in
            SVProgressHUD.showError(withStatus: "\(error.desc)")
        }
        
    }
    
    func updateChannelDetail(channelId: String, param: Dictionary<String, String>, successCompletion:(() -> Void)?) {
        SVProgressHUD.show()
        RCSCChannelDetailUpdateApi(channelId: channelId, param: param).fetch().success { object in
            SVProgressHUD.showSuccess(withStatus: "社区信息更新成功")
            if let successCompletion = successCompletion {
                successCompletion()
            }
        }
    }
    
    func setChannelNoticeType(communityId: String, channelId: String, noticeType: RCSCChannelNotifySettingNoticeType) {
        RCSCChannelNotifySettingApi(communityId: communityId, channelId: channelId, noticeType: noticeType).fetch().success { object in
            SVProgressHUD.showSuccess(withStatus: "频道通知设置成功")
        }.failed { error in
            SVProgressHUD.showError(withStatus: "\(error.desc)")
        }
    }
}

