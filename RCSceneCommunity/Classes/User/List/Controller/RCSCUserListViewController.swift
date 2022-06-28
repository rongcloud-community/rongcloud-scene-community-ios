//
//  RCSCUserListViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/13.
//

import UIKit
import SVProgressHUD

protocol RCSCUserListViewControllerDelegate: NSObjectProtocol {
    func selectUser(user: RCSCCommunityUser)
    func userTotalCount(count: Int, userType: RCSCCommunityUserType)
    func cellMoreAction(user: RCSCCommunityUser, indexPath: IndexPath)
}

extension RCSCUserListViewControllerDelegate {
    func selectUser(user: RCSCCommunityUser) {}
    func userTotalCount(count: Int, userType: RCSCCommunityUserType) {}
    func cellMoreAction(user: RCSCCommunityUser, indexPath: IndexPath) {}
}

class RCSCUserListViewController: UIViewController {
    
    let header: MJRefreshNormalHeader = {
        let header = MJRefreshNormalHeader()
        return header
    }()
    
    @objc private func refresh() {
        fetchUsers()
    }
    
    var refreshEnable = true {
        didSet {
            if !refreshEnable {
                tableView.mj_header = nil
            }
        }
    }
    
    let footer: MJRefreshAutoNormalFooter = {
        let footer = MJRefreshAutoNormalFooter()
        return footer
    }()
    
    @objc private func loadMore() {
        loadMoreUsers()
    }
    
    var loadMoreEnable = true {
        didSet {
            if !loadMoreEnable {
                tableView.mj_footer = nil
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RCSCUserListCell.self, forCellReuseIdentifier: RCSCUserListCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.mj_header = header
        tableView.mj_footer = footer
        return tableView
    }()
    
    var dataSource = Array<RCSCCommunityUser>()
    
    var keyWord: String? {
        didSet {
            fetchUsers()
        }
    }

    var pageNum = 1
    let pageSize = 20
    
    weak var delegate: RCSCUserListViewControllerDelegate?
    
    let communityId: String
    
    let selectType: RCSCCommunityUserType
    
    let cellType: RCSCUserListCellType
    
    let isCreator: Bool
    
    init(communityId: String, selectType: RCSCCommunityUserType, cellType: RCSCUserListCellType, isCreator: Bool = false) {
        self.communityId = communityId
        self.selectType = selectType
        self.cellType = cellType
        self.isCreator = isCreator
        super.init(nibName: nil, bundle: nil)
        RCSCCommunityService.service.registerListener(listener: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "社区成员"
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadMore))
        buildSubViews()
        fetchUsers()
        NotificationCenter.default.addObserver(self, selector: #selector(userListUpdate(notification:)), name: RCSCUserInfoCacheUpdateNotification, object: nil)
    }
    
    private func buildSubViews() {
        
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func fetchUsers() {
        pageNum = 1
        RCSCCommunityService.service.fetchCommunityUsers(communityUid: communityId, selectType: selectType, pageNum: pageNum, pageSize: pageSize, nickName: keyWord)
    }
    
    private func loadMoreUsers() {
        pageNum = pageNum + 1
        RCSCCommunityService.service.fetchCommunityUsers(communityUid: communityId, selectType: selectType, pageNum: pageNum, pageSize: pageSize, nickName: keyWord)
    }
    
    func reloadData() {
        fetchUsers()
    }

    @objc private func userListUpdate(notification: Notification) {
        guard let object = notification.object as? RCSCCommunityUserInfo,
              let userInfo = notification.userInfo,
              let communityId = userInfo[kCacheCommunityIdKey] as? String,
              let userId = userInfo[kCacheUserIdKey] as? String
        else { return }
        if self.communityId == communityId {
            for (index, user) in dataSource.enumerated() {
                if user.userUid == userId, let cacheUser = RCSCUserInfoCacheManager.getUserInfo(with: communityId, userId: userId){
                    var newUser = dataSource[index]
                    newUser.name = cacheUser.nickName
                    dataSource[index] = newUser
                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    break
                }
            }
        }
    }
}

extension RCSCUserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCUserListCell.reuseIdentifier, for: indexPath) as! RCSCUserListCell
        cell.data = dataSource[indexPath.row]
        cell.type = cellType
        cell.hideMoreButton = !isCreator
        cell.moreAction = { [weak self] in
            guard let self = self else { return }
            self.delegate?.cellMoreAction(user: self.dataSource[indexPath.row], indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        delegate?.selectUser(user: data)
    }
}

extension RCSCUserListViewController: RCSCCommunityDataSourceDelegate {
    func fetchUsersInfoSuccess(model: RCSCCommunityUserListModel, pageNum: Int, userType: RCSCCommunityUserType) {
        guard userType == selectType else { return }
        let users = model.records
        if (pageNum == 1) {
            header.endRefreshing()
            dataSource.removeAll()
            dataSource = users
            tableView.reloadData()
        } else {
            footer.endRefreshing()
            if users.count == 0 {
                SVProgressHUD.showInfo(withStatus: "没有更多数据")
                return
            }
            dataSource = dataSource + users
            tableView.reloadData()
        }
        loadMoreEnable = users.count == pageSize
        delegate?.userTotalCount(count: model.total, userType: selectType)
    }
}

extension RCSCUserListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        keyWord = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        keyWord = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        keyWord = nil
    }
}
