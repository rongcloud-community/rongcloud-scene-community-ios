//
//  RCSCCommunityMemberVerifySettingViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/25.
//

import UIKit
import SVProgressHUD

extension RCSCCommunityNeedAuditType {
    func text() -> String {
        switch self {
        case .free:
            return "不需要审核"
        case .need:
            return "需要审核才能加入"
        }
    }
}

class RCSCCommunityMemberVerifySettingViewController: UIViewController {
    
    var needRefreshDetail: ((Int) -> Void)?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCCommunityNotifySettingCell.self, forCellReuseIdentifier: RCSCCommunityNotifySettingCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.separatorColor = Asset.Colors.grayEDEDED.color
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    let dataSource: Array<RCSCCommunityNeedAuditType> = [.free,.need]
    
    var selectedAuditType = RCSCCommunityManager.manager.currentDetail.needAudit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "成员验证"
        buildSubViews()
        RCSCCommunityManager.manager.registerListener(listener: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = dataSource.firstIndex(of: selectedAuditType) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    private func buildSubViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RCSCCommunityMemberVerifySettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityNotifySettingCell.reuseIdentifier, for: indexPath) as! RCSCCommunityNotifySettingCell
        cell.text = dataSource[indexPath.row].text()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 57 : 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return RCSCSectionTextHeader(text:"新用户申请加入社区的验证设置", align: .center)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAuditType = dataSource[indexPath.row]
        RCSCCommunityManager.manager.updateCommunity(communityId: RCSCCommunityManager.manager.currentDetail.uid, param: ["needAudit":selectedAuditType.rawValue])

    }
    
}

extension RCSCCommunityMemberVerifySettingViewController: RCSCCommunityDataSourceDelegate {
    func updateCommunityInfo(_ isSuccess: Bool){
        if isSuccess {
            RCSCCommunityManager.manager.currentDetail.needAudit = selectedAuditType
//            if selectedAuditType == .free { //???: 放弃本地通知,来回切换,会重复发通知;而后台只会发一次
//                NotificationCenter.default.post(name: RCSCCommunityReceiveSystemMessageNotificationLocal, object: nil, userInfo: [RCSCCommunitySystemMessageIdKey: RCSCCommunityManager.manager.currentDetail.uid])
//            }
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        }
    }
}
