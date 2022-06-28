//
//  RCSCChannelNotifySettingViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/24.
//

import UIKit
import SVProgressHUD

extension RCPushNotificationLevel {
    func text() -> String {
        switch self {
        case .allMessage:
            return "所有消息都通知"
        case .default:
            return "跟随社区设置"
        case .blocked:
            return "从不通知"
        default:
            return "仅被@时通知"
        }
    }
}

extension RCSCActionSheetViewControllerActionType {
    func getNotificationLevel() -> RCPushNotificationLevel {
        switch self {
        case .followCommunity:
            return .default
        case .all:
            return .allMessage
        case .at:
            return .mention
        case .never:
            return .blocked
        default:
            return .allMessage
        }
    }
}

class RCSCChannelNotifySettingViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCChannelNotifySettingCell.self, forCellReuseIdentifier: RCSCChannelNotifySettingCell.reuseIdentifier)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 28))
        header.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.tableHeaderView = header
        return tableView
    }()
    
    lazy var dataSource = communityDetail.groupList
    
    var communityDetail: RCSCCommunityDetailData
    
    var communityId: String {
        get {
            return communityDetail.uid
        }
    }
    
    init(communityDetail: RCSCCommunityDetailData) {
        self.communityDetail = communityDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "频道通知设置"
        view.backgroundColor = .white
        buildSubViews()
    }
    
    private func buildSubViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

let semaphore = DispatchSemaphore(value: 1)

extension RCSCChannelNotifySettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let on = dataSource[section].on {
            return on ? dataSource[section].channelList.count : 0
        } else {
            return  dataSource[section].channelList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCChannelNotifySettingCell.reuseIdentifier, for: indexPath) as! RCSCChannelNotifySettingCell
        let channelData = dataSource[indexPath.section].channelList[indexPath.row]
        cell.name = channelData.name
        cell.channelId = channelData.uid
        cell.contentView.backgroundColor = .white
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            semaphore.wait()
            RCSCConversationMessageManager.getChannelNotificationType(communityId: self.communityDetail.uid, channelId: channelData.uid, success: { level in
                if level == .default {
                    RCSCConversationMessageManager.getCommunityNotificationType(communityId: self.communityId) { defaultLevel in
                        RCSCConversationMessageManager.setChannelNotificationType(communityId: self.communityId, channelId: channelData.uid, level: defaultLevel) {
                            semaphore.signal()
                            DispatchQueue.main.async {
                                cell.currentStatusText = defaultLevel.text()
                            }
                        } error: { code in
                            semaphore.signal()
                            debugPrint("获取社区默认通知信息失败 code：\(code.rawValue)")
                        }

                    } error: { code in
                        semaphore.signal()
                        debugPrint("设置频道通知失败 code：\(code.rawValue)")
                    }

                } else {
                    semaphore.signal()
                    DispatchQueue.main.async {
                        cell.currentStatusText = level.text()
                    }
                }
            }, error: { code in
                semaphore.signal()
                debugPrint("获取频道通知设置信息失败 code：\(code.rawValue)")
            })
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = RCSCSectionToolHeader(openEnable: true)
        sectionHeader.sectionName = dataSource[section].name
        sectionHeader.section = section
        sectionHeader.on = dataSource[section].on ?? true
        sectionHeader.disableCreate = true
        sectionHeader.backgroundColor = .white
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RCSCActionSheetViewController(dataSource: [.all, .at, .never])
        let channelId = dataSource[indexPath.section].channelList[indexPath.row].uid
        vc.didSelect = {[weak self] type in
            guard let self = self else { return }
            RCSCConversationMessageManager.setChannelNotificationType(communityId: self.communityId, channelId: channelId, level: type.getNotificationLevel()) {
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            } error: { code in
                SVProgressHUD.showError(withStatus: "频道通知设置失败")
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}

class RCSCChannelNotifySettingCell: RCSCCommunityDetailListCell {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.black949494.color
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Images.arrowIcon.image)
        return imageView
    }()
    
    var channelId: String?
    
    var currentStatusText: String? {
        didSet {
            label.text = currentStatusText ?? "跟随社区设置"
        }
    }
    override class var reuseIdentifier: String {
        get {
            return String(describing: RCSCChannelNotifySettingCell.self)
        }
    }
    
    override var unReadNumber: Int32 {
        willSet {
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        containerView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(Asset.Images.arrowIcon.image.size)
        }
        containerView.addSubview(label)
        label.snp_makeConstraints { make in
            make.centerY.equalTo(arrowImageView)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-4)
        }
    }
}
