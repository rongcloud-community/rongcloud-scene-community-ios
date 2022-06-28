//
//  RCSCConversationViewController+MediaBrowser.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/26.
//

import Foundation
import KNPhotoBrowser
import SVProgressHUD

extension RCSCMessageType {
    func mediaType() -> RCSCImagePickerMediaType? {
        switch self {
        case .text:
            return nil
        case .image:
            return .image
        case .video:
            return .video
        default:
            return nil
        }
    }
}

extension UIViewController {
    func browseMedia(with type: RCSCMessageType, message: RCMessage, sourceView: UIView) {
        //图片消息
        
        if type == .image,
            let content = message.content as? RCImageMessage {
            browseImage(content: content, sourceView: sourceView)
        }
        
        //视频消息
        if type == .video,
            let content = message.content as? RCSightMessage {
            browseVideo(content: content, sourceView: sourceView)
        }
        
        if type == .quote,
           let content = message.content as? RCReferenceMessage {
            if content.referMsg is RCImageMessage, let content = content.referMsg as? RCImageMessage {
                browseImage(content: content, sourceView: sourceView)
            } else if content.referMsg is RCSightMessage, let content = content.referMsg as? RCSightMessage {
                browseVideo(content: content, sourceView: sourceView)
            }
        }
    }
    
    
    
    
    func browseImage(content: RCImageMessage, sourceView: UIView) {
        let item: KNPhotoItems = KNPhotoItems()
        item.sourceView = sourceView
        
        var initialized = false
        if let path = content.realLocalPath(),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let image = UIImage(data: data) {
            item.sourceImage = image
            initialized = true
        } else if let url = content.remoteUrl {
            item.url = url
            initialized = true
        }
        if initialized {
            let browser = KNPhotoBrowser()
            browser.delegate = self
            browser.itemsArr = [item]
            browser.isNeedLongPress = true
            browser.currentIndex = 0
            browser.animatedMode = .scaleAspectFill
            browser.present()
        } else {
            SVProgressHUD.showError(withStatus: "图片资源错误, 请检查图片URL、图片本地路径")
        }
    }
    
    func browseVideo(content: RCSightMessage, sourceView: UIView) {
        let item: KNPhotoItems = KNPhotoItems()
        item.sourceView = sourceView
        item.isVideo = true
        var initialized = false
        if let path = content.realLocalPath() {
            initialized = true
            item.url = path
        } else if let url = content.sightUrl {
            initialized = true
            item.url = url
        }
        if initialized {
            let browser = KNPhotoBrowser()
            browser.delegate = self
            browser.isNeedOnlinePlay = true
            browser.isNeedAutoPlay = true
            browser.isNeedLongPress = true
            browser.itemsArr = [item]
            browser.currentIndex = 0
            browser.animatedMode = .scaleAspectFill
            browser.present()
        } else {
            SVProgressHUD.showError(withStatus: "视频播放失败，请检查资源地址")
        }
    }
}

var actionSheetOnScreen = false

extension UIViewController: KNPhotoBrowserDelegate {
    
    func downloadMediaToAlbum(photoBrowser: KNPhotoBrowser) {
        guard !actionSheetOnScreen else { return }
        let browserActionSheet = KNActionSheet(title: "", cancelTitle: "取消", titleArray: ["保存"]) {[weak self] index in
            actionSheetOnScreen = false
            guard let self = self, index != -1 else { return }
            UIDevice.deviceAlbumAuth { auth in
                if auth {
                    SVProgressHUD.show()
                    photoBrowser.downloadImageOrVideoToAlbum()
                } else {
                    SVProgressHUD.showError(withStatus: "当前相册没有写入权限，请检查授权状态")
                }
            }
        }
        browserActionSheet.show(on: photoBrowser.view)
        actionSheetOnScreen = true
    }
    
    public func photoBrowser(_ photoBrowser: KNPhotoBrowser, imageLongPressWith index: Int) {
        downloadMediaToAlbum(photoBrowser: photoBrowser)
    }
    
    public func photoBrowser(_ photoBrowser: KNPhotoBrowser, videoLongPress longPress: UILongPressGestureRecognizer, index: Int) {
        downloadMediaToAlbum(photoBrowser: photoBrowser)
    }
    
    public func photoBrowser(_ photoBrowser: KNPhotoBrowser, state: KNPhotoDownloadState, progress: Float, photoItemRelative photoItemRe: KNPhotoItems, photoItemAbsolute photoItemAb: KNPhotoItems) {
        if state == .saveSuccess {
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        } else if state == .saveFailure {
            SVProgressHUD.showError(withStatus: "保存失败")
        }
    }
}
