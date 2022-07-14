//
//  RCSCNameCacheManager.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/18.
//

import Foundation

let RCSCUserInfoCacheUpdateNotification = NSNotification.Name(rawValue: "RCSCUserInfoCacheUpdateNotification")

let kCacheCommunityIdKey = "communityId"

let kCacheUserIdKey = "userId"

class RCSCUserInfoCacheManager: NSObject, NSCacheDelegate {
    
    private let cache = NSCache<AnyObject, AnyObject>()
    
    static let manager = RCSCUserInfoCacheManager()
    
    var pool = Set<String>()
    
    let queue = DispatchQueue(label: "name.cache.queue", attributes: .concurrent)

    private override init() {
        super.init()
        cache.delegate = self
        cache.evictsObjectsWithDiscardedContent = true
        cache.totalCostLimit = 1000
    }
    
    func request(key: String, execute: @escaping ((Bool)->Void)) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if (!self.pool.contains(key)) {
                self.addKey(key: key)
                execute(true)
            } else {
                execute(false)
            }
            
        }
    }
    
    func removeKey(key: String) {
        let task = DispatchWorkItem(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.pool.remove(key)
        }
        queue.async(execute: task)
    }
    
    func addKey(key: String) {
        let task = DispatchWorkItem(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.pool.insert(key)
        }
        queue.async(execute: task)
    }
    
    private func getUserInfo(with communityId: String, userId: String, completion: ((RCSCCommunityUserInfo?) -> Void)? = nil) -> RCSCCommunityUserInfo? {
        let key = communityId+userId
        guard let userInfo = cache.object(forKey: key as AnyObject) as? RCSCCommunityUserInfo  else {
            request(key: key) {[weak self] res in
                if !res, let completion = completion {
                    return completion(nil)
                }
                RCSCCommunityUserInfoApi(communityUid: communityId, userUid: userId).fetch().success { object in
                    self?.removeKey(key: key)
                    guard let self = self, let object = object else { return }
                    self.cache.setObject(object, forKey: key as AnyObject)
                    if let completion = completion {
                        completion(object)
                    }
                    NotificationCenter.default.post(name: RCSCUserInfoCacheUpdateNotification, object: object, userInfo: [kCacheCommunityIdKey: communityId, kCacheUserIdKey: userId])
                }.failed { error in
                    self?.removeKey(key: key)
                    if let completion = completion {
                        //没有加入社区返货nil
                        completion(nil)
                    }
                }
            }
            return nil
        }
        
        if let completion = completion {
            completion(userInfo)
        }
        return userInfo
    }
    
    private func setUserInfo(with communityId: String, userId: String, userInfo: RCSCCommunityUserInfo) {
        let key = communityId+userId
        cache.setObject(userInfo, forKey: key as AnyObject)
    }
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        debugPrint("obj will be evict \(obj)")
    }
    
    static func getUserInfo(with communityId: String, userId: String, completion: ((RCSCCommunityUserInfo?) -> Void)? = nil) -> RCSCCommunityUserInfo? {
        return manager.getUserInfo(with: communityId, userId: userId, completion: completion)
    }
    
    static func setUserInfo(with communityId: String, userId: String, userInfo: RCSCCommunityUserInfo) {
        return manager.setUserInfo(with: communityId, userId: userId, userInfo: userInfo)
    }
}
 
