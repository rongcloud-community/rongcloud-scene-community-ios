//
//  RCSCImagePickerController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/7.
//

import UIKit
import Photos
import HXPHPicker
import SVProgressHUD


enum RCSCImagePickerMediaType:Int {
    case image = 1
    case video
}

extension RCSCImagePickerMediaType {
    func mediaTypes() -> Array<String> {
        switch self {
        case .image:
            return ["public.image"]
        case .video:
            return ["public.movie"]
        }
    }
}

typealias RCSCImagePickerImageSelectedCompletion = ((UIImage?) -> Void)
typealias RCSCImagePickerVideoSelectedCompletion = ((_ url: URL?, _ phAsset: PHAsset?) -> Void)
 
class RCSCImagePickerController: NSObject {
    
    private static let shared: RCSCImagePickerController = RCSCImagePickerController()
    
    lazy var imagePickerConfig: PickerConfiguration = {
        let config = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectOptions = .photo
        config.selectMode = .single
        config.maximumSelectedPhotoCount = 4
        config.maximumSelectedVideoCount = 4
        config.allowLoadPhotoLibrary = true
        config.photoList.sort = .desc
        config.photoList.allowAddCamera = true
        return config
    }()
    
    private override init() {
        super.init()
    }
    
    private var imageSelectedCompletionClosure: RCSCImagePickerImageSelectedCompletion?
    private var videoSelectedCompletionClosure: RCSCImagePickerVideoSelectedCompletion?
    private var cancelClosure: (() -> Void)?
    private var mediaType: RCSCImagePickerMediaType?
    
    static func showImagePicker(in viewController: UIViewController,
                                with mediaType: RCSCImagePickerMediaType = .image,
                                selectMode: PickerSelectMode = .single,
                                imageSelectedCompletionClosure: RCSCImagePickerImageSelectedCompletion?,
                                videoSelectedCompletionClosure:RCSCImagePickerVideoSelectedCompletion?,
                                cancelClosure:(() -> Void)?) {
        Self.shared.imageSelectedCompletionClosure = imageSelectedCompletionClosure
        Self.shared.videoSelectedCompletionClosure = videoSelectedCompletionClosure
        Self.shared.cancelClosure = cancelClosure
        Self.shared.mediaType = mediaType
        Self.shared.imagePickerConfig.selectMode = selectMode
        Self.shared.imagePickerConfig.selectOptions = mediaType == .image ? .photo : .video
        authorization {
            SVProgressHUD.dismiss()
            let imagePicker = PhotoPickerController.init(config: Self.shared.imagePickerConfig)
            imagePicker.pickerDelegate = Self.shared
            imagePicker.autoDismiss = false
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
        
    private static func authorization(closure: @escaping (() -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .denied || status == .restricted) {
            SVProgressHUD.showError(withStatus: "相册无访问权限，请去Setting设置")
        } else if (status == .notDetermined) {
            PHPhotoLibrary.requestAuthorization { result in
                DispatchQueue.main.async {
                    if (result == .restricted || result == .denied) {
                        SVProgressHUD.showError(withStatus: "拒绝授权相册权限")
                    } else if (result == .authorized) {
                        closure()
                        debugPrint("同意授权相册权限")
                    }
                }
            }
        } else {
            closure()
        }
    }
}

extension RCSCImagePickerController: PhotoPickerControllerDelegate {
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
        if mediaType == .image {
            guard let imageClosure = imageSelectedCompletionClosure else { return }
            for asset in result.photoAssets {
                if asset.mediaType == .photo {
                    if let originalImage = asset.originalImage {
                        imageClosure(originalImage)
                    }
                }
            }
        } else if mediaType == .video {
            guard let videoClosure = videoSelectedCompletionClosure else { return }
            for asset in result.photoAssets {
                if asset.mediaType == .video {
                    asset.requestVideoURL { result in
                        switch result {
                        case .success(let obj):
                            videoClosure(obj.url,asset.phAsset)
                            break
                        case .failure(let err):
                            videoClosure(nil,nil)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func pickerController(didCancel pickerController: PhotoPickerController) {
        pickerController.dismiss(animated: true, completion: nil)
        guard let cancelClosure = cancelClosure else { return }
        cancelClosure()
    }
}
