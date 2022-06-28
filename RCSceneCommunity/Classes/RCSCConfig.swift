//
//  RCSCConfig.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/31.
//

import Foundation

public class RCSCConfig {
    
    private static var config: RCSCConfig!
    
    static private(set) var serviceHost = config.serviceHost
    
    static private(set) var businessToken = config.businessToken
    
    private let serviceHost: String
    private let businessToken: String
    
    private init(serviceHost: String, businessToken: String) {
        self.serviceHost = serviceHost
        self.businessToken = businessToken
    }
    
    public static func loadConfig(serviceHost: String, businessToken: String) {
        self.config = RCSCConfig(serviceHost: serviceHost, businessToken: businessToken)
    }
}

