//
//  RCSCUserInfoDataSource.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/9.
//

import Foundation
import RongCloudOpenSource

class RCSCUserInfoDataSource: NSObject, RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        RCSCUserInfoApi(userIds: [userId]).fetch().success { list in
            if let list = list, let obj = list.first {
                let info = RCUserInfo(userId: obj.userId, name: obj.userName, portrait: obj.portrait)
                completion(info)
            } else {
                debugPrint("用户信息数据异常")
                completion(nil)
            }
            
        }.failed { error in
            debugPrint("用户信息获取失败")
            completion(nil)
        }
    }
}
