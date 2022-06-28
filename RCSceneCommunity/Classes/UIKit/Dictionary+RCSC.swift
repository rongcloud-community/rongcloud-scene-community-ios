//
//  Dictionary+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/16.
//

extension Dictionary {
    func getJsonString() -> String? {
        if !JSONSerialization.isValidJSONObject(self) {
            fatalError("数据错误，无法解析")
        }
        if let data = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
