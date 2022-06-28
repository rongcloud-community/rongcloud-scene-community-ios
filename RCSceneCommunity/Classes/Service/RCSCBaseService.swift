//
//  RCSCCommunityDataCenter.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/31.
//

import Foundation
import SVProgressHUD

class RCSCBaseService: NSObject {
    
    private let queue = DispatchQueue(label: "community_data_center", attributes: .concurrent)

    static var listeners: Array<RCSCBox<AnyObject>> = []
    
    override init() {
        super.init()
        print("RCSCBaseService init")
    }
    
// MARK: register listeners
    func registerListener(listener: AnyObject) {
        let task = DispatchWorkItem(flags: .barrier) { [weak self] in
            guard let _ = self else { return }
            Self.listeners.append(RCSCBox(value: listener))
        }
        queue.async(execute: task)
    }
        
    func execute<T>(protocol:T.Type ,closure:@escaping((_ listener: T) -> Void)) {
        Self.listeners = Self.listeners.filter({ (box) -> Bool in
            return box.value != nil
        })
        queue.async { [weak self] in
            guard let _ = self else { return }
            for box in Self.listeners {
                if let obj = box.value as? T {
                    DispatchQueue.main.async {
                        closure(obj)
                    }
                }
            }
        }
    }
}
