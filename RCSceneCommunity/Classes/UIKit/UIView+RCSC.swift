//
//  UIView+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/9.
//

import UIKit

extension UIView {
    func rcscCorner(corners: UIRectCorner, radii: CGFloat) {
        layer.masksToBounds = true
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    func blink(setColor: UIColor, repeatCount: Float, duration: Double) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = UIColor.white.cgColor
        animation.toValue = setColor.cgColor
        animation.duration = duration
        animation.autoreverses = true
        animation.isRemovedOnCompletion = true
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey: nil)
        
    }
}

extension UIView {
    var controller: UIViewController? {
        var tmp = next
        while let responder = tmp {
            if responder.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
            tmp = tmp?.next
        }
        return nil
    }
}
