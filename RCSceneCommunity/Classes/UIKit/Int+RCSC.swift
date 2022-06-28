//
//  Int+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/26.
//

import Foundation

extension Int64 {
    var timeString: String {
        var content = String()
        let seconds: Int = Int(self / 1000)
        if seconds < 10 {
            content = "刚刚"
        } else if seconds < 60 {
            content = "\(seconds)秒"
        } else if seconds < 3600 {
            content = "\(seconds / 60)分钟"
        } else {
            let date = Date(timeIntervalSince1970: TimeInterval(seconds))
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 hh:mm tt"
            content = formatter.string(from: date)
        }
        return content
    }
}
