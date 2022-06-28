//
//  RCSCPrivateMsgChatListVC.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/3.
//

import UIKit
import SVProgressHUD
//import RongIMKit
import RongCloudOpenSource
import JXSegmentedView

class RCSCPrivateMsgChatListVC: RCConversationListViewController {
    public var canCallComing: Bool = false
    public init(_ type: RCConversationType) {
        super.init(displayConversationTypes: [type.rawValue], collectionConversationType: [])
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        conversationListTableView.separatorStyle = .singleLine
        conversationListTableView.separatorColor = UIColor("#E3E5E6")
        conversationListTableView.separatorInset = UIEdgeInsets(top: 0, left: 71, bottom: 0, right: 0)
        conversationListTableView.backgroundColor = .clear
        conversationListTableView.tableFooterView = UIView()
        
        let botomLineview: UIView = {
            let view = UIView()
            view.backgroundColor = Asset.Colors.grayEDEDED.color
            return view
        }()
        view.addSubview(botomLineview)
        botomLineview.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
//        navigationItem.title = "消息"
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    public override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        guard let userId = model.targetId else { 
            return
        }
        let userIds = [userId]
        SVProgressHUD.show()
        RCSCGetSysUserInfoApi(userIds).fetch().success { [weak self] object in
            SVProgressHUD.dismiss()
            guard let self = self else { return  }
            guard let repo = object else { return }
            guard repo.count > 0 else { return }
            let user:RCSCSysMsgUserInfo = repo[0]
            let portraitUrl :String
            if let conunt = user.portrait?.count, conunt > 0 {
                portraitUrl =  user.portrait!.handeAvatarFullPath()
            }else {
                portraitUrl = RCSCDefaultAvatar
            }
             
            let userInfo = RCUserInfo(userId: user.userId, name: user.userName, portrait: portraitUrl)
            RCIM.shared().refreshUserInfoCache(userInfo, withUserId: user.userId)
            let controller = RCSCPrivateMsgChatVC(.ConversationType_PRIVATE, userId: userId)
            controller.canCallComing = self.canCallComing
            self.show(controller, sender: self)
        }.failed { error in
            SVProgressHUD.dismiss()
            print("RCSCGetSysUserInfoApi -> \(error)")
        }
    }
    
    public override func rcConversationListTableView(_ tableView: UITableView!, heightForRowAt indexPath: IndexPath!) -> CGFloat {
        return 72
    }
    
    public override func willDisplayConversationTableCell(_ cell: RCConversationBaseCell!, at indexPath: IndexPath!) {
        super.willDisplayConversationTableCell(cell, at: indexPath)
        guard let cell = cell as? RCConversationCell else {
            return
        }
        cell.selectionStyle = .none
        cell.conversationTitle.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cell.conversationTitle.textColor = UIColor(hexString: "#111F2C")
        cell.messageContentLabel.font = UIFont.systemFont(ofSize: 14)
        cell.messageContentLabel.textColor = UIColor(hexString: "#A0A5AB")
        cell.messageCreatedTimeLabel.font = UIFont.systemFont(ofSize: 13)
        cell.messageCreatedTimeLabel.textColor = UIColor(red: 0.73, green: 0.75, blue: 0.79, alpha: 0.6)
        cell.bubbleTipView.bubbleTipBackgroundColor = Asset.Colors.pinkF31D8A.color
    }
    
//    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//    }

}

extension RCSCPrivateMsgChatListVC:JXSegmentedListContainerViewListDelegate{
    func listView() -> UIView {
        return self.view
    }

    func listDidAppear() {
        debugPrint("\(type(of: self))-> listDidAppear")
    }
    
    func listDidDisappear() {
        debugPrint("\(type(of: self))-> listDidDisappear")
    }
    
}
