//
//  RCSCBundle.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/9.
//

class RCSCBundle: Bundle {
    static var bundleURL: URL {
        let bundleURL = Bundle(for: RCSCBundle.self).bundleURL
        return bundleURL.appendingPathComponent("RCSceneCommunity.bundle")
    }

    static var sharedBundle: RCSCBundle? {
        let url = bundleURL
        return RCSCBundle(url: url)
    }
}
