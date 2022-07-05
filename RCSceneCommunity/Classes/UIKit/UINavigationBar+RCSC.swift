//
//  UINavigationBar+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

import Foundation
import UIKit

public extension UINavigationBar {
    public func defaultAppearance() {
        setBackgroundImage(UIImage.createImageWithColor(color: .white), for: .default)
        isTranslucent = false
        backIndicatorImage = Asset.Images.naviBackIcon.image
        backIndicatorTransitionMaskImage = Asset.Images.naviBackIcon.image
        titleTextAttributes = [.foregroundColor : UIColor.black]
        tintColor = .black
        barTintColor = .white
        shadowImage = UIImage.createImageWithColor(color: Asset.Colors.grayE5E8EF.color)
//        if #available(iOS 15.0, *) {
//            let navBarAppearance = UINavigationBarAppearance()
//            navBarAppearance.configureWithOpaqueBackground()
//            navBarAppearance.shadowImage = UIImage.createImageWithColor(color: Asset.Colors.grayE5E8EF.color)
//            standardAppearance = navBarAppearance
//            scrollEdgeAppearance = navBarAppearance
//        }
    }
}
