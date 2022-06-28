//
//  FileManager+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/27.
//

import Foundation

extension FileManager {
    
    private func communityDocument() -> String {
        let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let communityPath = libraryPath + "/Caches/rcsccommunity"
        var isDirectory: ObjCBool = false
        if !(FileManager.default.fileExists(atPath: communityPath, isDirectory: &isDirectory) && isDirectory.boolValue) {
            do {
                try FileManager.default.createDirectory(atPath: communityPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                fatalError("本地媒体缓存文件夹创建失败")
            }
        }
        return communityPath
    }
    
    func copyMedia(mediaURL: URL) -> String? {
        var filePath: String?
        if let fileName = mediaURL.path.fileName() {
            let doc = communityDocument()
            filePath = doc + "/\(fileName)"
            do {
                try FileManager.default.copyItem(at: mediaURL, to: URL(fileURLWithPath: filePath!))
            }
            catch {
                fatalError("拷贝媒体文件失败")
            }
        }
        return filePath
    }
    
    func deleteMedia(mediaPath: String?) {
        if let mediaPath = mediaPath, FileManager.default.isDeletableFile(atPath: mediaPath) {
            do {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: mediaPath))
            }
            catch {
                fatalError("删除本地资源文件失败")
            }
        }
    }
}
