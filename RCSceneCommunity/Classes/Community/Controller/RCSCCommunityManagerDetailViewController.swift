//
//  RCSCCommunityManagerDetailViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/25.
//

import UIKit
import SVProgressHUD

enum RCSCCommunityManagerDetailActionType {
    case editInfo
    case memberVerify
    case blocked
    case dissolve
}

private extension RCSCCommunityManagerDetailActionType {
    var title: String {
        switch self {
        case .editInfo:
            return "编辑资料"
        case .memberVerify:
            return "成员验证"
        case .blocked:
            return "封禁管理"
        case .dissolve:
            return "解散社区"
        }
    }
}

class RCSCCommunityManagerDetailViewController: UIViewController {
    public var communityId: String {
        get {
            return communityDetail.uid
        }
    }
    
    /// 记录初始 manager.currentDetail
    let reccommunityEditInfoViewDetail = RCSCCommunityManager.manager.currentDetail
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCArrowCell.self, forCellReuseIdentifier: RCSCArrowCell.reuseIdentifier)
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
    
    let dataSource: Array<Array<RCSCCommunityManagerDetailActionType>> = [[.editInfo,.memberVerify],[.dissolve]]
    
    let communityDetail: RCSCCommunityDetailData
    
    init(communityDetail: RCSCCommunityDetailData) {
        self.communityDetail = communityDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "社区管理"
        buildSubViews()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.reccommunityEditInfoViewDetail != RCSCCommunityManager.manager.currentDetail {
            // 进行刷新操作
            NotificationCenter.default.post(name: RCSCCommunityDetailChangedNotification, object: nil)
        }
    }
    
    private func buildSubViews() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RCSCCommunityManagerDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCArrowCell.reuseIdentifier, for: indexPath) as! RCSCArrowCell
        let type = dataSource[indexPath.section][indexPath.row]
        cell.text = type.title
        cell.arrowView.isHidden = type == .dissolve
        cell.titleLabel.textColor = type == .dissolve ? Asset.Colors.redD43030.color : Asset.Colors.black949494.color
        return  cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 38 : 19
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.section][indexPath.row]
        switch type {
        case .editInfo:
            let vc = RCSCCommunityEditInfoViewController()
            vc.communityId = communityId
            navigationController?.pushViewController(vc, animated: true)
            break
        case .memberVerify:
            let vc = RCSCCommunityMemberVerifySettingViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
        case .blocked:
            break
        case .dissolve:
            showAlert(with: "解散社区") { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
                RCSCCommunityManager.manager.deleteCommunity()
            }
            break
        }
    }
}
