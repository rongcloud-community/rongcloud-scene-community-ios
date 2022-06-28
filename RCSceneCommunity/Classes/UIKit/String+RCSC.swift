//
//  String+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/27.
//

import Foundation

extension String {    
    func fileName() -> String? {
        if let fileName = self.md5 {
            return fileName.replacingOccurrences(of: "/", with: "") + "." + URL(fileURLWithPath: self).pathExtension
        }
        return nil
    }
    
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
    
    func textCheckResult(with pattern: String) -> Array<NSTextCheckingResult>? {
        do {
            let regex = try NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
            let result = regex.matches(in: self, options: .reportProgress, range: NSRange(location: 0, length: self.count))
            return result
        }
        catch {
            fatalError("字符串匹配失败")
        }
    }
    
//    func ranges(string: String) -> [Range<String.Index>] {
//        var rangeArray = [Range<String.Index>]()
//        var searchedRange: Range<String.Index>
//        guard let sr = self.range(of: self) else {
//            return rangeArray
//        }
//        searchedRange = sr
//
//        var resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
//        while let range = resultRange {
//            rangeArray.append(range)
//            searchedRange = Range(uncheckedBounds: (range.upperBound, searchedRange.upperBound))
//            resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
//        }
//        return rangeArray
//    }
//
//    func covertRangeToNSRange(range: Range<String.Index>) -> NSRange {
//        return NSRange(range, in: self)
//    }
    
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
    
    func getNSRanges(string: String) -> Array<NSRange> {
        let ranges = ranges(of: string)
        return ranges.map({ NSRange($0, in: self) })
    }
    
    func getDictionary() -> NSDictionary? {
        let jsonData = self.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if let dict = dict {
            return dict as? NSDictionary
        }
        return nil
    }
}

extension NSRange {
    
}

extension String {
    func handeAvatarFullPath() -> String {
        if self.hasPrefix("http") {
           return self
        }else{
           return "\(kHost)/file/show?path=\(self)"
        }
    }
}
