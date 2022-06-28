//
//  RCSCConvertAble.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/19.
//

public protocol ConvertAble: Codable {}

public extension ConvertAble {

    func convertToDict() -> Dictionary<String, Any>? {

        var dict: Dictionary<String, Any>? = nil

        do {
            print("init student")
            let encoder = JSONEncoder()

            let data = try encoder.encode(self)
            print("struct convert to data")

            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>

        } catch {
            print(error)
        }

        return dict
    }
}
