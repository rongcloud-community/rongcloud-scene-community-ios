//
//  RCSCMessagePluginView.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/9.
//

import UIKit

protocol RCSCMessagePluginView where Self: UIView {
    func updateUI(_ value: String)
}


class RCSCMessagePluginTextView: UIView {
}

extension RCSCMessagePluginTextView: RCSCMessagePluginView {
    func updateUI(_ value: String) {
        
    }
}
