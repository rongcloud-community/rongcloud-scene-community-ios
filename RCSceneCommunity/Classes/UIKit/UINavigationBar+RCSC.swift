//
//  UINavigationBar+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

import Foundation
import UIKit

extension UINavigationBar {
    static func defaultAppearance() {
        UINavigationBar.appearance().setBackgroundImage(UIImage.createImageWithColor(color: .white), for: .default)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backIndicatorImage = Asset.Images.naviBackIcon.image
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = Asset.Images.naviBackIcon.image
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.black]
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().shadowImage = UIImage.createImageWithColor(color: Asset.Colors.grayE5E8EF.color)
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.shadowImage = UIImage.createImageWithColor(color: Asset.Colors.grayE5E8EF.color)
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            
        }
    }
}
