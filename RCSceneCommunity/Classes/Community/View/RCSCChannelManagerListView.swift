//
//  RCSCGroupManagerListView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/15.
//

import UIKit
import TableViewDragger
import SVProgressHUD

enum RCSCChannelManagerListStyle {
    case channel
    case group
}

extension RCSCChannelManagerListStyle {
    
    func id(groupList: Array<RCSCCommunityDetailGroup>, indexPath: IndexPath) -> String {
        switch self {
        case .channel:
            return groupList[indexPath.section].channelList[indexPath.row].uid
        case .group:
            return groupList[indexPath.row].uid
        }
    }
    
    func name(groupList: Array<RCSCCommunityDetailGroup>, indexPath: IndexPath) -> String {
        switch self {
        case .channel:
            return groupList[indexPath.section].channelList[indexPath.row].name
        case .group:
            return groupList[indexPath.row].name
        }
    }
    func numberOfSection(groupList: Array<RCSCCommunityDetailGroup>) -> Int {
        switch self {
        case .channel:
            return groupList.count
        case .group:
            return 1
        }
    }
    
    func numberRowInSection(groupList: Array<RCSCCommunityDetailGroup>, section: Int) -> Int {
        switch self {
        case .channel:
            return groupList[section].channelList.count
        case .group:
            return groupList.count
        }
    }
    
    func sectionHeaderHeight() -> CGFloat {
        switch self {
        case .channel:
            return 44
        case .group:
            return 0
        }
    }
    
    func sectionHeader(title: String, section: Int) -> UIView {
        switch self {
        case .channel:
            let sectionHeader = RCSCSectionToolHeader(openEnable: false)
            sectionHeader.sectionName = title
            sectionHeader.section = section
            sectionHeader.disableCreate = true
            return sectionHeader
        case .group:
            return UIView()
        }
    }
    
    func updateType() -> RCSCCommunityEditDetailType {
        switch self {
        case .channel:
            return .channel
        case .group:
            return .group
        }
    }
}

class RCSCChannelManagerListView: UIView {

    private lazy var dragger: TableViewDragger = {
        let dragger = TableViewDragger(tableView: tableView)
        dragger.availableHorizontalScroll = true
        dragger.dataSource = self
        dragger.delegate = self
        dragger.alphaForCell = 0.7
        return dragger
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(RCSCChannelManagerListCell.self, forCellReuseIdentifier: RCSCChannelManagerListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        return tableView
    }()
    
    var beginEdit: ((_ inputView: UIView) -> Void)?
    
    var endEdit: ((_ inputView: UIView) -> Void)?
    
    let type: RCSCChannelManagerListStyle
    
    public var groupList = Array<RCSCCommunityDetailGroup>()
    
    init(type: RCSCChannelManagerListStyle) {
        self.type = type
        super.init(frame: .zero)
        let _ = dragger
        
        groupList = RCSCCommunityManager.manager.currentDetail.groupList

        if type == .channel {
            var defaultGroup = RCSCCommunityDetailGroup(uid: "", name: "根目录", sort: 0, on: true, channelList: RCSCCommunityManager.manager.currentDetail.channelList)
            groupList.insert(defaultGroup, at: 0)
        }
        
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func deleteRow(_ id: String,_ indexPath: IndexPath) {
        if type == .group {
            deleteGroupRow(id,indexPath)
        } else {
            deleteChannelRow(id,indexPath)
        }
    }
    
    func deleteGroupRow(_ groupId: String,_ indexPath: IndexPath) {
        showAlert(with: "确认删除分组？") { [weak self] in
            guard let self = self else { return }
            RCSCGroupDeleteApi(groupUid: groupId).fetch().success { msg in
                DispatchQueue.main.async {
                    self.groupList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }.failed { error in
                SVProgressHUD.showError(withStatus: "\(error.desc)")
            }
            
        }

    }
    
    func deleteChannelRow(_ channelId: String,_ indexPath: IndexPath) {
        showAlert(with: "确认删除频道？") { [weak self] in
            guard let self = self else { return }
            RCSCChannelDeleteApi(channelUid: channelId).fetch().success { _ in
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.groupList[indexPath.section].channelList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }.failed { error in
                SVProgressHUD.showError(withStatus: "\(error.desc)")
            }
        }
    }
    
    func editName(_ id: String,_ name: String,_ indexPath: IndexPath) {
        if type == .group {
            editGroupName(id, name, indexPath)
        } else {
            editChannelName(id, name, indexPath)
        }
    }
    
    func editGroupName(_ groupId: String,_ name: String,_ indexPath: IndexPath) {
        groupList[indexPath.row].name = name
    }
    
    func editChannelName(_ channelId: String,_ name: String,_ indexPath: IndexPath) {
        groupList[indexPath.section].channelList[indexPath.row].name = name
    }
    
    func showAlert(with title: String, confirmCompletion: @escaping (() -> Void)) {
        guard let controller = self.controller else { return }
        controller.showAlert(with: title, confirmCompletion: confirmCompletion)
    }
}

extension RCSCChannelManagerListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let number = type.numberOfSection(groupList: groupList)
        return number
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  type.numberRowInSection(groupList: groupList, section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCChannelManagerListCell.reuseIdentifier, for: indexPath) as! RCSCChannelManagerListCell
        cell.name = type.name(groupList: groupList, indexPath: indexPath)
        cell.id = type.id(groupList: groupList, indexPath: indexPath)
        cell.type = type
        cell.beginEdit = beginEdit
        cell.endEdit = endEdit
        cell.editName = {[weak self] id, name in
            guard let self = self else { return }
            self.editName(id, name, indexPath)
        }
        
        cell.delete = {[weak self] id in
            guard let self = self else { return }
            self.deleteRow(id, indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return type.sectionHeader(title: groupList[section].name, section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return type.sectionHeaderHeight()
    }
}

extension RCSCChannelManagerListView: TableViewDraggerDataSource, TableViewDraggerDelegate {
    func dragger(_ dragger: TableViewDragger, moveDraggingAt indexPath: IndexPath, newIndexPath: IndexPath) -> Bool {
        if (type == .channel) {
            let item = groupList[indexPath.section].channelList[indexPath.row]
            groupList[indexPath.section].channelList.remove(at: indexPath.row)
            groupList[newIndexPath.section].channelList.insert(item, at: newIndexPath.row)
            RCSCCommunityManager.manager.currentDetail.channelList = groupList.first!.channelList
        } else {
            let item = groupList[indexPath.row]
            groupList.remove(at: indexPath.row)
            groupList.insert(item, at: newIndexPath.row)
        }
        tableView.moveRow(at: indexPath, to: newIndexPath)
        return true
    }
}
