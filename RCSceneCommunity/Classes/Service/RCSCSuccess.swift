//
//  RCSCSuccess.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/30.
//

import Foundation

public struct RCSCEmptyData: Codable {}

public struct RCSCSuccess<T: Codable>: Codable {
    public var code: Int?
    public var data: T?
    public var msg: String?
    
    func isSuccess() -> Bool {
        return code == 10000
    }
}
