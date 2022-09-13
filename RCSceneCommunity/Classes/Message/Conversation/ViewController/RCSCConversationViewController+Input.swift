//
//  RCSCConversationViewController+Input.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/16.
//

import SVProgressHUD
import HXPHPicker

extension RCSCConversationViewController: RCSCTmpInputViewProtocol {
    
    func inputViewDidClickSend(_ text: String, _ atUsers: Array<RCSCCommunityUser>?) {
        guard var pushContent = self.pushContent, checkUserStatus() else {
            return debugPrint("消息发送失败，请检查pushcontent是否设置正常，当前用户是否被禁言")
        }
        DispatchQueue.global().async {
            pushContent.content = text
            MsgMgr.sendTextMessage(text: text, communityId: self.communityId, channelId: self.channelId, atUsers: atUsers, pushContent: pushContent)
        }
    }
    
    func inputViewDidSelectedMediaType(_ type: RCSCMessageType) {
        //发送多媒体消息
        guard var pushContent = self.pushContent, checkUserStatus() else {
            return debugPrint("消息发送失败，请检查pushcontent是否设置正常，当前用户是否被禁言")
        }
        guard let mediaType = type.mediaType() else { return }
        
        RCSCImagePickerController.showImagePicker(in: self, with: mediaType, selectMode: .multiple) {[weak self] image in
            guard let self = self,
                  let image = image
            else { return }
            pushContent.content = "[图片]"
            RCSCConversationMessageManager.sendImageMessage(image: image, communityId: self.communityId, channelId: self.channelId, pushContent: pushContent)
            self.dismiss(animated: true, completion: nil)
        } videoSelectedCompletionClosure: {[weak self] url, phAsset in
            guard let self = self,
                  let videoURL = url,
                  let asset = phAsset
            else { return }
            let duration = asset.duration
            let option = PHImageRequestOptions()
            option.resizeMode = .fast
            option.isSynchronous = true
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 138, height: 106), contentMode: .default, options: option) { image, value in
                DispatchQueue.main.async {
                    if let image = image, let path = FileManager.default.copyMedia(mediaURL: videoURL) {
                        pushContent.content = "[视频]"
                        RCSCConversationMessageManager.sendVideoMessage(videoPath: path, thumbnail: image, duration: UInt(ceil(duration)), communityId: self.communityId, channelId: self.channelId, pushContent: pushContent)
                    } else {
                        SVProgressHUD.showError(withStatus: "视频封面获取失败")
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } cancelClosure: {
            debugPrint("image picker dismiss")
        }


    }
    
    func quoteMessageDidClickSend(_ text: String, _ message: RCMessage, _ opt: RCSCMessageOperation, _ atUsers: Array<RCSCCommunityUser>?) {
        //校验当前消息是否支持当前的操作
        guard var pushContent = self.pushContent, checkUserStatus() else {
            return debugPrint("消息发送失败，请检查pushcontent是否设置正常，当前用户是否被禁言")
        }
        if (opt.isValid(message)) {
            if opt == .edit {
                RCSCConversationMessageManager.modifyMessage(messageUid: message.messageUId ?? "",
                                                             text: text,
                                                             atUsers: atUsers) {[weak self] success, code in
                    guard let self = self else { return }
                    if success {
                        self.modifyMessageFinished()
                    } else {
                        SVProgressHUD.showError(withStatus: "消息修改失败")
                    }
                }
            } else if opt == .quote {
                pushContent.content = text
                RCSCConversationMessageManager.sendQuoteMessage(quoteMessage: message, text: text, atUsers: atUsers, pushContent: pushContent)
                self.modifyMessageFinished()
            }
        } else {
            SVProgressHUD.showError(withStatus: "当前消息不支持此操作")
        }
        
    }
    
    
    func jumpUserListViewController() {
        let usersList = RCSCAtMessageUserListViewController(communityId: communityId)
        usersList.delegate = self
        navigationController?.pushViewController(usersList, animated: true)
    }
    
    func inputViewTyping() {
        RCSCConversationMessageManager.sendTypingMessage(communityId: communityId, channelId: channelId)
    }
    
    func checkUserStatus() -> Bool {
        let result = communityDetail.communityUser.shutUp == 0
        if !result {
            SVProgressHUD.showError(withStatus: "您被禁止在该社区发言")
        }
        return result
    }
}
 
extension RCSCConversationViewController: RCSCUserListViewControllerDelegate {
    func selectUser(user: RCSCCommunityUser) {
        navigationController?.popToViewController(self, animated: true)
        tmpInputView.atUsers.append(user)
    }
}
