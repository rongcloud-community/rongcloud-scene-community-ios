//
//  RCSCDiscoverService.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation

class RCSCDiscoverService: RCSCBaseService {
    
    static let service = RCSCDiscoverService()
    
    private override init() {
        super.init()
    }
}

protocol RCSCDiscoverServiceDelegate: NSObjectProtocol {
    func fetchDiscoverListSuccess(list: Array<RCSCDiscoverListRecord>?) -> Void
    func fetchTmpCommunity(detail: RCSCCommunityDetailData?, error: RCSCError?)
}

extension RCSCDiscoverServiceDelegate {
    func fetchDiscoverListSuccess(list: Array<RCSCDiscoverListRecord>?) -> Void {}
    func fetchTmpCommunity(detail: RCSCCommunityDetailData?, error: RCSCError?) {}
}

extension RCSCDiscoverService {
    func fetchDiscoverList(pageNum: Int, pageSize: Int) {
        RCSCDiscoverListApi(pageNum: pageNum, pageSize: pageSize).fetch().success {[weak self] object in
            guard let self = self else { return }
            self.execute(protocol: RCSCDiscoverServiceDelegate.self) { listener in
                listener.fetchDiscoverListSuccess(list: object?.records)
            }
        }
    }
    
    func fetchTmpCommunityDetail(communityId: String) {
        RCSCCommunityDetailApi.init(communityId: communityId).fetch().success {[weak self] object in
            if let detail = object {
                self?.execute(protocol: RCSCDiscoverServiceDelegate.self) { listener in
                    listener.fetchTmpCommunity(detail: detail, error: nil)
                }
            }
        }.failed {[weak self] error in
            self?.execute(protocol: RCSCDiscoverServiceDelegate.self) { listener in
                listener.fetchTmpCommunity(detail: nil, error: error)
            }
        }
    }
}
