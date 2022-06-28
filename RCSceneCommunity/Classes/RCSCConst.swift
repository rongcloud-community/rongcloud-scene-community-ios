//
//  RCSCConst.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/22.
//

import UIKit

let RCSCKb = 1024
let RCSCMb = 1024 * 1024

let kScreenWidth    = UIScreen.main.bounds.width
let kScreenHeight   = UIScreen.main.bounds.height

let kConversationAtMessageTypeKey = "mentionedContent"

let RCSCDefaultAvatar = "https://cdn.ronghub.com/demo/default/rce_default_avatar.png"

enum RCSCReeditType: String {
    case normal = "0"
    case reedit = "1"
}

enum RCSCTextAlignment {
    case top
    case center
    case bottom
    case left
    case right
}
