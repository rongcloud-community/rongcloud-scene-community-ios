//
//  RCSceneCommunityHomeViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/7.
//

import SVProgressHUD
import UIKit

open class RCSCHomeViewController: RCSCBaseViewController {
    
    lazy var communityListView: RCSCCommunityListView = {
        let communityListView = RCSCCommunityListView()
        communityListView.createCommunityHandler = { [weak self] in
            guard let self = self else { return }
            let createVC = RCSCCommunityCreateViewController()
            self.navigationController?.pushViewController(createVC, animated: true)
        }
        return communityListView
    }()
    
    lazy var communityDetailView: RCSCCommunityDetailView = {
        let communityDetailView = RCSCCommunityDetailView()
        communityDetailView.delegate = self
        return communityDetailView
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let net = RCSCNetworkReachabilityManager()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initializedModule()
        registerServiceListener()
        registerNotification()
        buildSubViews()
        fetchCommunityListData()
        net?.startListening(onUpdatePerforming: {[weak self] status in
            guard let self = self else { return }
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self.fetchCommunityListData()
                break
            default:
                break
            }
        })
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initializedModule() {
        ModuleInitialization.initialized()
        RCSCCommunityManager.initialized()
        RCSCConversationMessageManager.initialized()
    }
    
    func registerServiceListener() {
        RCSCCommunityManager.manager.registerListener(listener: self)
        RCSCDiscoverService.service.registerListener(listener: self)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(communityDetailChanged), name: RCSCCommunityDetailChangedNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addTmpCommunity(notification:)), name: RCSCDiscoverViewControllerAddTmpCommunityNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCommunitySystemMessage(notification:)), name: RCSCCommunityReceiveSystemMessageNotification, object: nil)
    }
    
    public func fetchCommunityListData() {
        guard let _ = RCSCUser.RCSCGetUser() else { return  }
        RCSCCommunityManager.manager.fetchCommunityList()
    }
    
    private func buildSubViews() {
        view.addSubview(communityListView)
        communityListView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.leading.equalTo(self.view)
            make.width.equalTo(78)
            make.bottom.equalToSuperview() //.offset(-UIDevice.vg_tabBarFullHeight())
        }
        
        view.addSubview(communityDetailView)
        communityDetailView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.leading.equalTo(communityListView.snp.trailing)
            make.trailing.equalTo(self.view).offset(-8)
            make.bottom.equalToSuperview() //.offset(-UIDevice.vg_tabBarFullHeight())
        }
    }
    
    func addTmpCommunity(detail: RCSCCommunityDetailData) {}
    
    @objc private func addTmpCommunity(notification: NSNotification?) {
        guard let notification = notification,
              let record = notification.object as? RCSCDiscoverListRecord,
              let tab = tabBarController
        else { return }
        tab.selectedIndex = 0
        communityListView.addTmpCommunityItem(record: record)
    }
    
    //MARK: - 修改数据后刷新社区信息
    @objc private func communityDetailChanged(noti: Notification) {
        if let communityId = noti.object as? String, RCSCCommunityManager.manager.currentDetail.uid == communityId {
            RCSCCommunityManager.manager.fetchDetail(communityId: communityId)
        } else {
            self.communityDetailView.currentDetail =  RCSCCommunityManager.manager.currentDetail 
        }
        fetchCommunityListData()
    }
    
    @objc private func receiveCommunitySystemMessage(notification: Notification) {
        if let type = notification.object as? RCSCSystemMessageType {
            switch type {
            case .quit, .joined, .kickOut:
                fetchCommunityListData()
                break
            case .dissolve:
                fetchCommunityListData()
                break
            default:
                break
            }
        }
    }
}

extension RCSCHomeViewController: RCSCCommunityDetailViewDelegate {
    func moreClick(communityDetail: RCSCCommunityDetailData) {
        guard let isHasUid =  communityDetailView.currentDetail?.uid.isEmpty , !isHasUid  else {
            return
        }
        
        guard  communityDetail.communityUser.auditStatus == .joined else {
            if let newSelectCommunityId = self.communityListView.removeTmpCommunityItem() {
                RCSCCommunityManager.manager.fetchDetail(communityId: newSelectCommunityId)
            } else {
                communityDetailView.currentDetail = nil
                
            }
            return
        }
        
        let communityManagerViewController = RCSCCommunityManagerPopViewController(communityDetail: communityDetail)
        communityManagerViewController.communityName = RCSCCommunityManager.manager.currentDetail.name
        communityManagerViewController.communityNumber = RCSCCommunityManager.manager.currentDetail.uid
        communityManagerViewController.avatarUrl = RCSCCommunityManager.manager.currentDetail.portrait
        communityManagerViewController.dismissCompletion = { [weak self] cellType in
            guard let self = self else { return }
            self.managerCommunity(actionType: cellType)
        }
        present(communityManagerViewController, animated: true, completion: nil)
    }
    
    func createChannel(groupData: RCSCCommunityDetailGroup) {
        let communityData = RCSCCommunityManager.manager.currentDetail
        let channelCreateVC = RCSCChannelCreateViewController(communityData: communityData, groupData: groupData)
        channelCreateVC.maximumNameLength = 16
        present(channelCreateVC, animated: true, completion: nil)
    }
    
    func editChannel() {
        let channelManagerVC = RCSCChannelManagerViewController(style:.channel)
        present(channelManagerVC, animated: true, completion: nil)
    }
    
    func editGroup() {
        let channelManagerVC = RCSCChannelManagerViewController(style:.group)
        present(channelManagerVC, animated: true, completion: nil)
    }
    
    func managerCommunity(actionType: RCSCCommunityManagerPopActionType) {
        let communityDetail = RCSCCommunityManager.manager.currentDetail
        switch actionType {
        case .usersList:
            let userListVC = RCSCCommunityUserListViewController(communityDetail: communityDetail)
            navigationController?.pushViewController(userListVC, animated: true)
            break
        case .nickName:
            let vc = RCSCEditTextViewController(headerTitle: "我在本社区的昵称")
            vc.maximumTextLength = 16
            vc.placeholder = communityDetail.communityUser.nickName
            vc.cancelHandler = { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            vc.saveHandler = { [weak self] nickName in
                guard let self = self,
                      let userId = RCSCUser.user?.userId
                else { return }
                let communityId = RCSCCommunityManager.manager.currentDetail.uid
                RCSCCommunityEditUserApi(communityId: communityId, userId: userId, param:  ["nickName":nickName]).fetch().success { object in
                    SVProgressHUD.showSuccess(withStatus: "保存成功")
                }
                self.dismiss(animated: true, completion: nil)
            }
            self.present(vc, animated: true, completion: nil)
            break
        case .createGroup:
            let vc = RCSCEditTextViewController(headerTitle: "创建分组")
            vc.maximumTextLength = 16
            vc.placeholder = "请填写分组名称"
            vc.cancelHandler = { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            vc.saveHandler = { [weak self] groupName in
                guard let self = self else { return }
                RCSCCommunityManager.manager.createGroup(name: groupName)
                self.dismiss(animated: true, completion: nil)
            }

            self.present(vc, animated: true, completion: nil)
            break
        case .createChannel:
            guard let groupData = RCSCCommunityManager.manager.currentDetail.groupList.first else {
                return
            }
            let communityData = RCSCCommunityManager.manager.currentDetail
            let channelCreateVC = RCSCChannelCreateViewController(communityData: communityData, groupData: groupData)
            channelCreateVC.maximumNameLength = 16
            self.present(channelCreateVC, animated: true, completion: nil)
            break
        case .notify:
            let notifyVC = RCSCCommunityNotifySettingViewController(communityDetail: RCSCCommunityManager.manager.currentDetail, title: "通知设置", desc: "设置所有文字/帖子频道的默认通知方式", style: .setting)
            navigationController?.pushViewController(notifyVC, animated: true)
            break
        case .manager:
            let communityMgrVC = RCSCCommunityManagerDetailViewController(communityDetail: RCSCCommunityManager.manager.currentDetail)
//            communityMgrVC.currentDetail = RCSCCommunityManager.manager.currentDetail
            navigationController?.pushViewController(communityMgrVC, animated: true)
            break
        case .quit:
            guard let userId = RCSCUser.user?.userId else {
                return SVProgressHUD.showError(withStatus: "当前用户未登录，请先执行登录操作")
            }
            RCSCCommunityManager.manager.saveCommunityUser(param: [kRCSCCommunityUserStatusKey: RCSCCommunityUserStatus.quite.rawValue], userId: userId)
            break
        }
    }

}

extension RCSCHomeViewController: RCSCDiscoverServiceDelegate {
    func fetchTmpCommunity(detail: RCSCCommunityDetailData?, error: RCSCError?) {
        if let detail = detail {
            addTmpCommunity(detail: detail)
        } else if let error = error {
            SVProgressHUD.showError(withStatus: "\(error.desc)")
        } else {
            SVProgressHUD.showError(withStatus: "网络错误")
        }
    }
}


class ModuleInitialization {
    static func initialized() {
        SVProgressHUD.setDefaultStyle(.dark)
    }
}
