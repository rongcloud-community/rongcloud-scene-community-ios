//
//  RCSCConversationViewController+Service.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/17.
//

extension RCSCConversationViewController: RCSCCommunityDataSourceDelegate {
    func joinCommunitySuccess() {
        RCSCCommunityService.service.fetchDetail(communityId: communityId)
    }
    
    func updateCommunityDetail(detail: RCSCCommunityDetailData?) {
        if let detail = detail {
            communityDetail = detail
            //TODO: 如下代码满足当前需求,后续需要改进
            if communityDetail.needAudit == .need {
                userStatusBottomBar.changeToCheckStatus()
            } else {
                tmpInputView.isHidden = false
                userStatusBottomBar.isHidden = true
            }
        }
    }
}
