//
//  RCSCPrivateMsgChatVC.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/4.
//

import UIKit
//import RongIMKit
import RongCloudOpenSource
import SVProgressHUD
class RCSCPrivateMsgChatVC: RCConversationViewController {
    
    public var canCallComing: Bool = false
    
    public init(_ type: RCConversationType, userId: String) {
        super.init(conversationType: type, targetId: userId)
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.Colors.whiteF5F6F9.color
        view.subviews.forEach {
            $0.backgroundColor = Asset.Colors.whiteF5F6F9.color
        }
        
        refreshUserInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ConversationType_PRIVATE_onSelectedTableRow"), object: nil)
    }
    private func refreshUserInfo() {
//        RCSceneUserManager.shared.fetchUserInfo(userId: targetId) { [weak self] user in
//            self?.navigationItem.title = user.userName
//        }
        SVProgressHUD.show()
        RCSCGetSysUserInfoApi([targetId]).fetch().success { [weak self] object in
            SVProgressHUD.dismiss()
            guard let self = self else { return  }
            guard let repo = object else { return }
            guard repo.count > 0 else { return }
            let user:RCSCSysMsgUserInfo = repo[0]
//            let portraitUrl :String
//            if let conunt = user.portrait?.count, conunt > 0 {
//                portraitUrl =  user.portrait!
//            }else {
//                portraitUrl = RCSCDefaultAvatar
//            }
             
            self.navigationItem.title = user.userName
           
        }.failed { error in
            SVProgressHUD.dismiss()
            print("RCSCGetSysUserInfoApi -> \(error)")
        }
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    public override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        super.willDisplayMessageCell(cell, at: indexPath)
        
        if let cell = cell as? RCTextMessageCell {
            if cell.model.messageDirection == .MessageDirection_SEND {
                cell.textLabel.textColor = .white
                cell.bubbleBackgroundView.tintColor = Asset.Colors.blue7983FE.color
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.textLabel.textColor = .black
                cell.bubbleBackgroundView.tintColor = UIColor.white
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            }
        } else if let cell = cell as? RCVoiceMessageCell {
            let tempImageView = ChatroomVoiceImageView(frame: .zero)
            tempImageView.image = cell.playVoiceView.image
            tempImageView.frame = cell.playVoiceView.frame
            cell.playVoiceView.removeFromSuperview()
            cell.messageContentView.addSubview(tempImageView)
            cell.playVoiceView = tempImageView
            if cell.model.messageDirection == .MessageDirection_SEND {
                cell.voiceDurationLabel.textColor = .white
                tempImageView.tintColor = .white
                cell.bubbleBackgroundView.tintColor = Asset.Colors.blue7983FE.color
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.voiceDurationLabel.textColor = .black
                tempImageView.tintColor = .black
                cell.bubbleBackgroundView.tintColor = UIColor.white
                cell.bubbleBackgroundView.image = cell.bubbleBackgroundView.image?.withRenderingMode(.alwaysTemplate)
            }
        }else if let cell = cell as? RCSightMessageCell { //FIXME: 还缺少补充一个视频类型的调试
            cell.bubbleBackgroundView.tintColor = UIColor.white
        }
        
    }
    
    public override func didTapMessageCell(_ model: RCMessageModel!) {
        //  call
        if model.content?.classForCoder.getObjectName() == "RC:VCSummary" {
            if !canCallComing {
                return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
            }
        }
        super.didTapMessageCell(model)
    }
    
    public override func pluginBoardView(_ pluginBoardView: RCPluginBoardView!, clickedItemWithTag tag: Int) {
        //  call
        if tag == 1101 || tag == 1102 {
            if canCallComing == false {
                return SVProgressHUD.showInfo(withStatus: "请先退出房间，再进行通话")
            }
        }
        super.pluginBoardView(pluginBoardView, clickedItemWithTag: tag)
    }
}

final class ChatroomVoiceImageView: UIImageView {
    override var image: UIImage? {
        get {
            super.image
        }
        set {
            super.image = newValue?.withRenderingMode(.alwaysTemplate)
        }
    }
}
