//
//  RCSCChannelCreateListView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

class RCSCChannelCreateListView: UIView {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(RCSCChannelCreateInputTextCell.self, forCellReuseIdentifier: RCSCChannelCreateInputTextCell.reuseIdentifier)
        tableView.register(RCSCChannelCreateCategoryCell.self, forCellReuseIdentifier: RCSCChannelCreateCategoryCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private weak var cell: UITableViewCell?
    
    var showSelectGroupViewHandler: (() -> Void)?
    
    var inputTextHandler: ((String?) -> Void)?
    
    var categoryDataSource: Array<(selected: Bool, locked: Bool, title: String, subTitle: String, selectedImage: UIImage, normalImage: UIImage)> = []
    
    private var groupData: RCSCCommunityDetailGroup
    
    init(groupData: RCSCCommunityDetailGroup) {
        self.groupData = groupData
        super.init(frame: .zero)
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
    
    func inputView() -> UIView? {
        guard let view = cell else {
            cell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            return cell
        }
        return view
    }
    
    func reloadData(with groupData: RCSCCommunityDetailGroup) {
        self.groupData = groupData
        tableView.reloadData()
    }
}

extension RCSCChannelCreateListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : categoryDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 44 : 62
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = RCSCChannelCreateSectionHeader()
        header.backgroundColor = .white
        header.text = section == 0 ? "所属分组：\(groupData.name)" : "频道类别："
        header.hideButton = section != 0
        header.selectGroupHandler = showSelectGroupViewHandler
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCChannelCreateInputTextCell.reuseIdentifier, for: indexPath) as! RCSCChannelCreateInputTextCell
            cell.inputTextHandler = inputTextHandler
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCChannelCreateCategoryCell.reuseIdentifier, for: indexPath) as! RCSCChannelCreateCategoryCell
            cell.data = categoryDataSource[indexPath.row]
            return cell
        }
    }
}
