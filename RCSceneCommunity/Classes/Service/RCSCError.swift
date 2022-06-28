//
//  RCSCError.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/11.
//

import Foundation

public struct RCSCError {
    let code: Int
    let desc: String
    
    init (_ code: Int, _ desc: String) {
        self.code = code
        self.desc = desc
    }
}
