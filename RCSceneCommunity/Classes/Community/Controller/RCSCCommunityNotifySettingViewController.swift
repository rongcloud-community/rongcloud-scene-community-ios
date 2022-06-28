//
//  RCSCCommunityNotifySettingViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/24.
//

import UIKit
import SVProgressHUD


extension RCSCCommunityNotifySettingType {
    var title: String {
        get {
            switch self {
            case .all:
                return "所有消息都通知"
            case .at:
                return "仅被@时通知"
            case .never:
                return "从不通知"
            case .custom:
                return "单独设置频道通知"
            }
        }
    }
    var pushNotificationLevel:RCPushNotificationLevel{
        get{
            switch self {
            case .all:
                return .allMessage
            case .at:
                return .mention
            case .never:
                return .blocked
            case .custom:
                return .`default`
            }
        }
    }
    
 
    
    func cell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .all, .at, .never:
            return tableView.dequeueReusableCell(withIdentifier: RCSCCommunityNotifySettingCell.reuseIdentifier, for: indexPath)
        case .custom:
            return tableView.dequeueReusableCell(withIdentifier: RCSCArrowCell.reuseIdentifier, for: indexPath)
        }
    }
}

enum RCSCCommunityNotifySettingStyle {
    case info
    case setting
}

extension RCSCCommunityNotifySettingStyle {
    func dataSource() -> Array<Array<RCSCCommunityNotifySettingType>> {
        switch self {
        case .info:
            return [[.all,.at]]
        case .setting:
            return [[.all,.at,.never],[.custom]]
        }
    }
    
    func fetchCurrentSelectType(communityDetail: RCSCCommunityDetailData, dataSource: Array<Array<RCSCCommunityNotifySettingType>>,  completion: @escaping ((RCSCCommunityNotifySettingType) -> Void)) {
        switch self {
        case .info:
            RCSCConversationMessageManager.getCommunityDefaultNotificationType(communityId: communityDetail.uid) { level in
                var type: RCSCCommunityNotifySettingType = .all
                if level == .default {
                    RCSCConversationMessageManager.setCommunityDefaultNotificationType(communityId: communityDetail.uid, level: .allMessage) {
                    } error: { code in
                    }
                } else {
                    for (index, notifyType) in dataSource[0].enumerated() {
                        if notifyType.pushNotificationLevel == level {
                            type = notifyType
                            break
                        }
                    }
                }
                completion(type)
            } error: { code in
                SVProgressHUD.showError(withStatus: "获取社区默认通知设置类型失败")
                debugPrint("notification default setting error code: \(code.rawValue)")
            }
        case .setting:
            RCSCConversationMessageManager.getCommunityNotificationType(communityId: communityDetail.uid) { level in
                var type: RCSCCommunityNotifySettingType = .all
                if level == .default {
                    RCSCConversationMessageManager.setCommunityNotificationType(communityId: communityDetail.uid, level: .allMessage) {
                    } error: { code in
                    }
                } else {
                    for (index, notifyType) in dataSource[0].enumerated() {
                        if notifyType.pushNotificationLevel == level {
                            type = notifyType
                            break
                        }
                    }
                }
                completion(type)
            } error: { code in
                SVProgressHUD.showError(withStatus: "获取社区通知设置类型失败")
                debugPrint("notification setting error code: \(code.rawValue)")
            }

        }
    }
    
    func setNotificationType(communityDetail: RCSCCommunityDetailData, noticeType: RCSCCommunityNotifySettingType) {
        let communityId = communityDetail.uid
        switch self {
        case .info:
            RCSCConversationMessageManager.setCommunityDefaultNotificationType(communityId: communityId, level: noticeType.pushNotificationLevel) {
                syncNoticeType(communityId: communityId, noticeType: noticeType)
            } error: { error in
                SVProgressHUD.showError(withStatus: "通知模式设置失败:\(error)")
            }
        case .setting:
            RCSCConversationMessageManager.setCommunityNotificationType(communityId: communityId, level: noticeType.pushNotificationLevel) {
                RCSCConversationMessageManager.setChildChannelNotificationSetting(communityDetail: communityDetail, level: noticeType.pushNotificationLevel)
            } error: { error in
                SVProgressHUD.showError(withStatus: "通知模式设置失败:\(error)")
            }
        }
    }
    
    func syncNoticeType(communityId: String, noticeType: RCSCCommunityNotifySettingType) {
        RCSCCommunityUpdateInfoApi(communityId: communityId, param: [RCSCParamNoticeTypeKey: noticeType.rawValue]).fetch().success { object in
            
        }.failed { error in
            
        }
    }
}
class RCSCCommunityNotifySettingViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCCommunityNotifySettingCell.self, forCellReuseIdentifier: RCSCCommunityNotifySettingCell.reuseIdentifier)
        tableView.register(RCSCArrowCell.self, forCellReuseIdentifier: RCSCArrowCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = Asset.Colors.grayEDEDED.color
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var dataSource: Array<Array<RCSCCommunityNotifySettingType>> {
        get {
            return style.dataSource()
        }
    }
    
    var desc = "设置所有文字/帖子频道的默认通知方式"
    
    var deselectPath: IndexPath?

    let communityDetail: RCSCCommunityDetailData
    
    let style: RCSCCommunityNotifySettingStyle
    
    init(communityDetail: RCSCCommunityDetailData, title: String, desc: String, style: RCSCCommunityNotifySettingStyle) {
        self.desc = desc
        self.communityDetail = communityDetail
        self.style = style
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildSubViews()
        fetchCommunityNotificationType()
        RCSCCommunityManager.manager.registerListener(listener: self)
    }
    
    private func buildSubViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func fetchCommunityNotificationType() {
        style.fetchCurrentSelectType(communityDetail: communityDetail, dataSource: dataSource) { type in
            DispatchQueue.main.async {
                let selectedRow = IndexPath(row: type.rawValue, section: 0)
                self.tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
            }
        }
    }
}

extension RCSCCommunityNotifySettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.section][indexPath.row]
        let cell = type.cell(tableView, indexPath) as! RCSCArrowCell
        cell.text = type.title
        cell.contentView.backgroundColor = .white
        return  cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 57 : 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = section == 0 ? desc : ""
        return RCSCSectionTextHeader(text:text, align: .center)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let userId = RCSCUser.user?.userId else {
                return SVProgressHUD.showError(withStatus: "当前用户未登录，请先执行登录操作")
            }
            let notifyType = dataSource[indexPath.section][indexPath.row]
            style.setNotificationType(communityDetail: communityDetail, noticeType: notifyType)
        
        } else {
            if let idx = deselectPath {
                tableView.selectRow(at: idx, animated: false, scrollPosition: .none)
            }
            let vc = RCSCChannelNotifySettingViewController(communityDetail: communityDetail)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        deselectPath = indexPath
    }
}

extension RCSCCommunityNotifySettingViewController :RCSCCommunityDataSourceDelegate {
    func updateCommunityInfo(_ isSuccess: Bool){
        SVProgressHUD.dismiss()
        if !isSuccess {
            SVProgressHUD.showSuccess(withStatus: "设置失败")
        }
    }
    
}

class RCSCCommunityNotifySettingCell: RCSCArrowCell {

    override class var reuseIdentifier: String {
        get {
            return String(describing: RCSCCommunityNotifySettingCell.self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        arrowView.image = selected ? Asset.Images.notifySettingSelectedIcon.image : Asset.Images.notifySettingNormalIcon.image
    }
    
    override func buildSubViews() {
        super.buildSubViews()
        arrowView.image = nil
        arrowView.snp.updateConstraints { make in
            make.size.equalTo(Asset.Images.notifySettingNormalIcon.image.size)
        }
    }
}
