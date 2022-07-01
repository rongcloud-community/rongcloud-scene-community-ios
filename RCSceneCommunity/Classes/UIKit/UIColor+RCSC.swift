//
//  UIColor+RCSce.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/8.
//
extension UIColor {
    /// UIColor components value between 0 to 255
    convenience init(byteRed red: Int, green: Int, blue: Int, alpha: Float = 1.0) {
        self.init(red: CGFloat(red)/255.0,
                  green: CGFloat(green)/255.0,
                  blue: CGFloat(blue)/255.0,
                  alpha: CGFloat(alpha))
    }
    
    func alpha(_ value: Float) -> UIColor {
        let (red, green, blue, _) = UIColorComponents()
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(value))
    }
    
    func red(_ value: Int) -> UIColor {
        let (_, green, blue, alpha) = UIColorComponents()
        return UIColor(red: CGFloat(value)/255.0, green: green, blue: blue, alpha: alpha)
    }
    
    func green(_ value: Int) -> UIColor {
        let (red, _, blue, alpha) = UIColorComponents()
        return UIColor(red: red, green: CGFloat(value)/255.0, blue: blue, alpha: alpha)
    }
    
    func blue(_ value: Int) -> UIColor {
        let (red, green, _, alpha) = UIColorComponents()
        return UIColor(red: red, green: green, blue: CGFloat(value)/255.0, alpha: alpha)
    }
    
    //swiftlint:disable large_tuple
    func UIColorComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #if os(iOS)
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(OSX)
        self.usingUIColorSpaceName(NSUIColorSpaceName.calibratedRGB)!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        return (red, green, blue, alpha)
    }
}
