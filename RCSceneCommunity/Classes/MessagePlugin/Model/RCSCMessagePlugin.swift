//
//  RCSCMessagePlugin.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/9.
//

import Foundation

typealias RCSCMessagePluginKey = String

let RCSCMessagePluginTextKey: RCSCMessagePluginKey = "RCSCMessagePluginTextKey"

let RCSCMessagePlugins: [String: RCSCMessagePluginView.Type] = [
    RCSCMessagePluginTextKey: RCSCMessagePluginTextView.self
]
