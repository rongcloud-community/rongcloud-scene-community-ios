//
//  RCSCChannelCreateSelectGroupView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/17.
//

import UIKit

class RCSCChannelCreateSelectGroupView: UIView {

    var didSelectGroupHandler: ((RCSCCommunityDetailGroup?) -> Void)?
    
    private lazy var header: RCSCConfirmSaveView = {
        let header = RCSCConfirmSaveView(showBackButton: true)
        header.title = "选择分组"
        header.hideSaveButton = true
        header.hideCancelButton = true
        header.saveHandler = {[weak self] in
            guard let self = self,
                  let block = self.didSelectGroupHandler
            else { return }
            block(self.groupData)
        }
        header.backHandler = {[weak self] in
            guard let self = self,
                  let block = self.didSelectGroupHandler
            else { return }
            block(nil)
        }
        return header
    }()
    
    var groups:Array<RCSCCommunityDetailGroup> {
        var defaultGroup = RCSCCommunityDetailGroup(uid: "", name: "根目录", sort: 0, on: true, channelList: RCSCCommunityManager.manager.currentDetail.channelList)
        return [defaultGroup] + RCSCCommunityManager.manager.currentDetail.groupList
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.register(RCSCChannelCreateSelectGroupViewCell.self, forCellReuseIdentifier: RCSCChannelCreateSelectGroupViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        let line = UIView()
        line.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 1)
        line.backgroundColor = Asset.Colors.grayF1F1F1.color
        tableView.tableHeaderView = line
        return tableView
    }()
    
    let groupData: RCSCCommunityDetailGroup
    
    init(groupData: RCSCCommunityDetailGroup) {
        self.groupData = groupData
        super.init(frame: .zero)
        backgroundColor = .white
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(40)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}

extension RCSCChannelCreateSelectGroupView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCChannelCreateSelectGroupViewCell.reuseIdentifier, for: indexPath) as! RCSCChannelCreateSelectGroupViewCell
        let groupData = groups[indexPath.row]
        cell.text = groupData.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupData = groups[indexPath.row]
        if let block = didSelectGroupHandler {
            block(groupData)
        }
    }
}

class RCSCChannelCreateSelectGroupViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: RCSCChannelCreateSelectGroupViewCell.self)
    
    var text: String = "" {
        willSet {
            contentLabel.text = newValue
        }
    }
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.grayC1C1C1.color
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayF1F1F1.color
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
