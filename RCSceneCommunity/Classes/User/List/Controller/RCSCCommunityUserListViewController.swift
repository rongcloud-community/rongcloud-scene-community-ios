//
//  RCSCUserListViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/11.
//

import UIKit
import SVProgressHUD

class RCSCCommunityUserListViewController: UIViewController {
    
    private lazy var searchBar: RCSCSearchBar = {
        let searchBar = RCSCSearchBar()
        searchBar.searchBarDelegate = onlineUserListVC
        return searchBar
    }()
    
    private lazy var categoryView: RCSCCategoryView = {
        let categoryView = RCSCCategoryView()
        categoryView.selectedIndex = 0
        categoryView.dataSource = categoryViewDataSource
        categoryView.delegate = self
        return categoryView
    }()
    
    private lazy var onlineUserListVC: RCSCUserListViewController = {
        let userListVC = RCSCUserListViewController(communityId: communityId, selectType: .online, cellType: .normal, isCreator: isCreator)
        userListVC.delegate = self
        userListVC.view.isHidden = false
        return userListVC
    }()
    
    private lazy var offlineUserListVC: RCSCUserListViewController = {
        let userListVC = RCSCUserListViewController(communityId: communityId, selectType: .offline, cellType: .normal, isCreator: isCreator)
        userListVC.delegate = self
        userListVC.view.isHidden = true
        return userListVC
    }()
    
    var currentUserListVC: RCSCUserListViewController {
        get {
            return currentUserType == . online ? onlineUserListVC : offlineUserListVC
        }
    }
    
    var categoryViewDataSource = [RCSCCategoryViewModel(title: "在线", count: 0, type: .online), RCSCCategoryViewModel(title: "离线", count: 0, type: .offline)]
    
    var currentUserType: RCSCCommunityUserType = .online
    
    var currentActionType: RCSCActionSheetViewControllerActionType?
    
    var communityId: String {
        get {
            return communityDetail.uid
        }
    }
    
    var isCreator: Bool {
        get {
            if let user = RCSCUser.user {
                return user.userId == communityDetail.creator
            } else {
                return false
            }
        }
    }
    
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
        view.backgroundColor = .white
        title = "社区成员"
        buildSubViews()
        RCSCCommunityManager.manager.registerListener(listener: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func buildSubViews() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.height.equalTo(44)
        }
        
        view.addSubview(categoryView)
        categoryView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        
        addChild(onlineUserListVC)
        view.addSubview(onlineUserListVC.view)
        onlineUserListVC.view.snp.makeConstraints { make in
            make.top.equalTo(categoryView.snp.bottom)
            make.trailing.leading.bottom.equalToSuperview()
        }
        
        addChild(offlineUserListVC)
        view.addSubview(offlineUserListVC.view)
        offlineUserListVC.view.snp.makeConstraints { make in
            make.edges.equalTo(onlineUserListVC.view)
        }
    }
    
    private func handleAction(with type: RCSCActionSheetViewControllerActionType, user: RCSCCommunityUser) {
        currentActionType = type
        switch type {
        case .editName:
            let editTextVC = RCSCEditTextViewController(headerTitle: "修改社区昵称")
            editTextVC.placeholder = user.name
            editTextVC.cancelHandler = { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }
            editTextVC.saveHandler = { [weak self] text in
                guard let self = self  else { return }
                RCSCCommunityManager.manager.saveCommunityUser(param: ["nickName":text], userId: user.userUid)
                self.dismiss(animated: true, completion: nil)
            }
            self.present(editTextVC, animated: true, completion: nil)
            break
        case .releaseMute:
            RCSCCommunityManager.manager.saveCommunityUser(param: [kRCSCCommunityUserMuteKey: 0], userId: user.userUid)
            break
        case .mute:
            let alertViewController = UIAlertController(title: "禁言成员", message: "禁止 \(user.name) 在本社区发言吗？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirmAction = UIAlertAction(title: "确定", style: .destructive) {[weak self] action in
                guard let self = self else { return }
                RCSCCommunityManager.manager.saveCommunityUser(param: [kRCSCCommunityUserMuteKey: 1], userId: user.userUid)
            }
            alertViewController.addAction(cancelAction)
            alertViewController.addAction(confirmAction)
            present(alertViewController, animated: true, completion: nil)
            break
        case .kickOut:
            RCSCCommunityManager.manager.saveCommunityUser(param: [kRCSCCommunityUserStatusKey: RCSCCommunityUserStatus.kick.rawValue], userId: user.userUid)
        default:
            break
        }
    }
}

extension RCSCCommunityUserListViewController: RCSCCategoryViewDelegate {
    func categoryViewDidSelect(index: Int, categoryModel: RCSCCategoryViewModel) {
        currentUserType = categoryModel.type
        onlineUserListVC.view.isHidden = categoryModel.type == .offline
        offlineUserListVC.view.isHidden = categoryModel.type == .online
        searchBar.searchBarDelegate = categoryModel.type == .offline ? offlineUserListVC : onlineUserListVC
    }
}

extension RCSCCommunityUserListViewController: RCSCUserListViewControllerDelegate {
    func userTotalCount(count: Int, userType: RCSCCommunityUserType) {
        for (index, categoryViewModel) in categoryViewDataSource.enumerated() {
            if categoryViewModel.type == userType {
                let model = RCSCCategoryViewModel(title: categoryViewModel.title, count: count, selected: categoryViewModel.selected, type: categoryViewModel.type)
                categoryViewDataSource[index] = model
                categoryView.dataSource = categoryViewDataSource
                break
            }
        }
    }
    
    func selectUser(user: RCSCCommunityUser) {
        
    }
    
    func cellMoreAction(user: RCSCCommunityUser, indexPath: IndexPath) {
        var dataSource: Array<RCSCActionSheetViewControllerActionType> = user.isMute ?  [.editName, .releaseMute, .kickOut] :  [.editName, .mute, .kickOut]
        if user.userUid == communityDetail.creator {
            dataSource = [.editName]
        }
        let actionSheetVC = RCSCActionSheetViewController(dataSource: dataSource)
        actionSheetVC.didSelect = {[weak self] type in
            guard let self = self else { return }
            self.handleAction(with: type, user: user)
        }
        self.present(actionSheetVC, animated: true, completion: nil)
    }
}


extension RCSCCommunityUserListViewController: RCSCCommunityDataSourceDelegate {
    func saveCommunityUserInfoSuccess(params: Dictionary<String, Any>) {
        switch currentActionType {
        case .kickOut:
            SVProgressHUD.showSuccess(withStatus: "已踢出社区")
        case .editName:
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        case .releaseMute:
            SVProgressHUD.showSuccess(withStatus: "取消禁言成功")
        case .mute:
            SVProgressHUD.showSuccess(withStatus: "禁言成功")
        default:
            break
        }
        //用户信息更新成功，刷新列表
        onlineUserListVC.reloadData()
        offlineUserListVC.reloadData()
    }
}
