//
//  RCSceneCommunityChannelListView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/7.
//

import SVProgressHUD
import UIKit


protocol RCSCCommunityDetailViewDelegate: AnyObject {
    func moreClick(communityDetail: RCSCCommunityDetailData)
    func createChannel(groupData: RCSCCommunityDetailGroup)
    func editChannel()
    func editGroup()
    func notifySetting()
}

extension RCSCCommunityDetailViewDelegate {
    func moreClick(communityDetail: RCSCCommunityDetailData) {}
    func createChannel(groupData: RCSCCommunityDetailGroup) {}
    func editChannel() {}
    func editGroup() {}
    func notifySetting() {}
}

class RCSCCommunityDetailView: UIView {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 76, left: 0, bottom: 0, right: 0)
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.register(RCSCCommunityDetailListCell.self, forCellReuseIdentifier: RCSCCommunityDetailListCell.reuseIdentifier)
        tableView.layer.masksToBounds = true
        let backgroundView = RCSCCommunityDetailEmptyView()
        backgroundView.isHidden = false
        backgroundView.createGroupHandler = {  [weak self] in
            print("创建社区")
            guard let self = self else { return }
            let createVC = RCSCCommunityCreateViewController()
            self.controller?.navigationController?.pushViewController(createVC, animated: true)
        }
        backgroundView.discoverGroupHandler = { [weak self] in
            print("发现社区")
            guard let self = self else { return }
            if let currentVc = self.controller as? RCSCHomeViewController {
                if let  vcArray = currentVc.tabBarController?.viewControllers {
                    for (index ,vc) in vcArray.enumerated() {
                        if vc is RCSCDiscoverViewController {
                            currentVc.tabBarController?.selectedIndex = index
                            return
                        }
                        if let nav = vc as? UINavigationController ,
                           let rootViewController = nav.viewControllers.first,
                             rootViewController is RCSCDiscoverViewController  {
                                currentVc.tabBarController?.selectedIndex = index
                        }

                    }
                            
                }
//                currentVc.tabBarController?.selectedIndex = 1 //FIXME: 后期可能需要调整为3
            }
            
        }
        tableView.backgroundView = backgroundView
        return tableView
    }()
    
    private lazy var header: RCSCCommunityDetailHeaderView = {
        let header = RCSCCommunityDetailHeaderView()
        header.communityId = currentDetail?.uid
        header.image = Asset.Images.bigIcon.image
        header.groupName = "融云实时社区"
        header.subName = "融云实时社区"
        header.action = { [weak self] in
            if let self = self, let delegate = self.delegate, let communityDetail = self.currentDetail{
                delegate.moreClick(communityDetail: communityDetail)
            }
        }
        return header
    }()
    
    
    private lazy var statusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = Asset.Colors.blue667C8A.color
        button.isHidden = true
        button.addTarget(self, action: #selector(joinCommunity), for: .touchUpInside)
        return button
    }()
    
    var currentDetail: RCSCCommunityDetailData? {
        willSet {
            if let currentDetail = newValue {
                updateUIWithCommunityDetail(currentDetail: currentDetail)
            } else {
                resetUI()
            }
        }
    }
    
    var isCreator: Bool {
        get {
            if let currentDetail = currentDetail, let userId = RCSCUser.user?.userId {
                return currentDetail.creator == userId
            }
            return false
        }
    }
    
    var dataSource = [RCSCCommunityDetailGroup]()
    
    weak var delegate: RCSCCommunityDetailViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Asset.Colors.grayF6F6F6.color
        buildSubViews()
        let press = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        press.minimumPressDuration = 1
        self.addGestureRecognizer(press)
        RCSCCommunityManager.manager.registerListener(listener: self)
        RCSCConversationMessageManager.setDelegate(delegate: self)
        registerNotification()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let _ = self.layer.mask else {
            return self.rcscCorner(corners: [.topLeft,.topRight], radii: 8)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(communityDetailViewReceiveCommunitySystemMessage(notification:)), name: RCSCCommunityReceiveSystemMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(modifyChannelDetail(notification:)), name: RCSCChannelDetailViewControllerModifyChannelNameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(modifyMuteStatus(notification:)), name: RCSCCommunityModifyMuteStatusNotification, object: nil)
        
    }
    
    private func buildSubViews() {
        
        addSubview(header)
        header.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(136)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(60)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        addSubview(statusButton)
        statusButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    
    private func updateUIWithCommunityDetail(currentDetail: RCSCCommunityDetailData) {
        //table
        dataSource.removeAll()
        var defaultGroup = RCSCCommunityDetailGroup(uid: "", name: "根目录", sort: 0, on: true, channelList: currentDetail.channelList)
        dataSource.append(defaultGroup)
        dataSource = dataSource + currentDetail.groupList
        tableView.reloadData()
        //header
        header.groupName = currentDetail.name
        header.imageUrl = currentDetail.coverUrl.isEmpty ? currentDetail.portrait : currentDetail.coverUrl
        header.moreButtonIsHidden = false
        statusButton.isHidden = currentDetail.communityUser.auditStatus == .joined
        statusButton.setTitle(currentDetail.communityUser.auditStatus.buttonTitle(), for: .normal)
        tableView.backgroundView?.isHidden = true
    }
    
    private func resetUI() {
        dataSource.removeAll()
        tableView.reloadData()
        header.groupName = "融云实时社区"
        header.imageUrl = nil
        header.status = .joined
        header.moreButtonIsHidden = true
        statusButton.isHidden = true
        tableView.backgroundView?.isHidden = false
    }
    
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        guard let user = RCSCUser.user, currentDetail?.creator == user.userId else {
            return
        }
        let touchPoint = longPress.location(in: tableView)
        guard let delegate = delegate else { return }
        if let _ = tableView.indexPathForRow(at: touchPoint) {
            delegate.editChannel()
        } else {
            delegate.editGroup()
        }
    }
    
    @objc private func communityDetailViewReceiveCommunitySystemMessage(notification: Notification) {
        if let type = notification.object as? RCSCSystemMessageType {
            switch type {
            case .reject:
                currentDetail?.communityUser.auditStatus = .reject
            case .mute, .release:
                currentDetail?.communityUser.shutUp = type == .mute ? 1 : 0
            case .joined:
                currentDetail?.communityUser.auditStatus = .joined
                if let currentDetail = currentDetail {
                    RCSCConversationMessageManager.initializeNotificationSettingWithServerData(communityId: currentDetail.uid)
                }
                
            default:
                break
            }
        }
    }
    
    @objc private func modifyChannelDetail(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let type = userInfo[RCSCChannelTypeKey] as? RCSCIntroViewControllerOperateType,
              let text = userInfo[RCSCChannelTextKey] as? String,
              let channelId = userInfo[RCSCChannelIdKey] as? String,
              var groupList = currentDetail?.groupList
        else { return }
        for (gIndex, grp) in groupList.enumerated() {
            var group = grp
            for (cIndex, chl) in group.channelList.enumerated() {
                if chl.uid == channelId {
                    if type == .channelName {
                        var channel = group.channelList[cIndex]
                        channel.name = text
                        group.channelList[cIndex] = channel
                        groupList[gIndex] = group
                        currentDetail?.groupList = groupList
                        //根目录默认为 section 0 所以 gIndex + 1
                        tableView.reloadRows(at: [IndexPath(row: cIndex, section: gIndex + 1)], with: .none)
                        return
                    }
                }
            }
        }
    }
    
    @objc private func modifyMuteStatus(notification: Notification) {
        guard let mute = notification.object as? Int
        else { return }
        currentDetail?.communityUser.shutUp = mute
    }
    
    @objc private func joinCommunity() {
        if let currentDetail = currentDetail, currentDetail.communityUser.auditStatus == .join || currentDetail.communityUser.auditStatus == .reject {
            RCSCCommunityService.service.joinCommunity(communityId: currentDetail.uid)
        }
    }
}

extension RCSCCommunityDetailView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityDetailListCell.reuseIdentifier, for: indexPath) as! RCSCCommunityDetailListCell
        let data = dataSource[indexPath.section].channelList[indexPath.row]
        cell.name = data.name
        if let communityId = currentDetail?.uid, let conversation = data.getConversation(communityId: communityId) {
            cell.unReadNumber = conversation.unreadMessageCount
        } else {
            cell.unReadNumber = 0
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.isScrollEnabled = dataSource.count != 0
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.count == 0 {
            return 0
        }
        
        if let on = dataSource[section].on {
            return on ? dataSource[section].channelList.count : 0
        } else {
            return  dataSource[section].channelList.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        } else {
            let sectionHeader = RCSCSectionToolHeader(openEnable: true)
            sectionHeader.sectionName = dataSource[section].name
            sectionHeader.section = section
            sectionHeader.on = dataSource[section].on ?? true
            sectionHeader.hideCreateChannelButton = !isCreator
            sectionHeader.groupOpenHandler = {[weak self] section in
                guard let self = self else {return}
                self.dataSource[section].on = !(self.dataSource[section].on ?? true)
                tableView.reloadSections([section], with: .fade)
            }
            sectionHeader.groupCreateHandler = {[weak self] _ in
                guard let self = self, let delegate = self.delegate, let user = RCSCUser.user, self.currentDetail?.creator == user.userId else {
                    return
                }
                delegate.createChannel(groupData: self.dataSource[section])
            }
            return sectionHeader
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 44 : 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension RCSCCommunityDetailView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.section].channelList[indexPath.row]
        guard let currentDetail = currentDetail else { return }
        let conversationViewController = RCSCConversationViewController(communityDetail: currentDetail, channelId: data.uid)
        conversationViewController.popViewControllerCompletion = { [weak self] in
            guard let self = self,
            indexPath.section < self.dataSource.count,
            indexPath.row < self.dataSource[indexPath.section].channelList.count
            else { return }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        controller?
            .navigationController?
            .pushViewController(conversationViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header.progress = (-scrollView.contentOffset.y/tableView.contentInset.top)
    }
}

extension RCSCCommunityDetailView: RCSCCommunityDataSourceDelegate {
    
    func updateCommunityDetail(detail: RCSCCommunityDetailData?) {
        currentDetail = detail
        if let detail = detail {
            header.status = detail.communityUser.auditStatus
            if RCSCCommunityManager.manager.needJumpToDefaultChannel {
                RCSCCommunityManager.manager.needJumpToDefaultChannel = false
                let conversationViewController = RCSCConversationViewController(communityDetail: detail, channelId: detail.joinChannelUid)
                controller?.navigationController?.pushViewController(conversationViewController, animated: true)
            }
        }
    }
    
    func updateCommunityList(list: Array<RCSCCommunityListRecord>?) {
        guard let list = list else {
            return currentDetail = nil
        }
        
        if let communityId = list.first?.communityUid {
            RCSCCommunityManager.manager.fetchDetail(communityId: communityId)
        } else {
            currentDetail = nil
        }
    }
    
    func createCommunitySuccess() {
        //创建社区后会拉取最新的社区列表，当前详情数据置空后 updateCommunityList 会重新拉取新创建的详情
        currentDetail = nil
    }
    
    func createChannelSuccess() {
        guard let communityId = currentDetail?.uid else { return }
        RCSCCommunityManager.manager.fetchDetail(communityId: communityId)
    }
    
    func deleteCommunitySuccess(communityId: String) {
        if currentDetail?.uid == communityId {
            currentDetail = nil
        }
    }
    
    func joinCommunitySuccess() {
        //guard let currentDetail = currentDetail else { return }
        //RCSCCommunityManager.manager.fetchDetail(communityId: currentDetail.uid)
    }
}

extension RCSCCommunityDetailChannel {
    func getConversation(communityId: String) -> RCConversation? {
        return RCSCConversationMessageManager.getConversation(communityId: communityId, channelId: uid)
    }
}

extension RCSCCommunityDetailView: RCSCConversationMessageManagerDelegate {
    
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        guard let communityId = currentDetail?.uid, message.targetId == communityId else { return }
        for (section, group) in dataSource.enumerated() {
            for (row, channel) in group.channelList.enumerated() {
                if channel.uid == message.channelId {
                    let indexPath = IndexPath(row: row, section: section)
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
}
