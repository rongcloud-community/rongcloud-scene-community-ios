//
//  UITabBar+RCSCBddge.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/25.
//

import UIKit

extension UITabBar {
    /**
     添加小红点

     - parameter index: index
     */
   public func showBadgeOnItemIndex(_ index : Int, _ itemCount: Int = 5){
        // 移除之前的小红点
        removeBadgeOnItemIndex(index)
        // 新建小红点
        let badgeView = UIView()
        badgeView.tag = 888 + index
        badgeView.layer.cornerRadius = 5
        badgeView.backgroundColor = Asset.Colors.pinkF31D8A.color
        let tabFrame = self.frame
        // 确定小红点的位置
        let percentX = (Double(index) + 0.6) / Double(itemCount)
        let x = ceilf(Float(percentX) * Float(tabFrame.size.width))
        let y = ceilf(0.09 * Float(tabFrame.size.height))

        badgeView.frame = CGRect.init(x: CGFloat(x), y: CGFloat(y), width: 10, height: 10)
        self.addSubview(badgeView)
    }

    public func hideBadgeOnItemIndex(_ index : Int){
        // 移除小红点
        removeBadgeOnItemIndex(index)
    }
    func removeBadgeOnItemIndex(_ index : Int){
        // 按照tag值进行移除
        for itemView in self.subviews {
            if(itemView.tag == 888 + index){
                itemView.removeFromSuperview()
            }
        }
    }
}

