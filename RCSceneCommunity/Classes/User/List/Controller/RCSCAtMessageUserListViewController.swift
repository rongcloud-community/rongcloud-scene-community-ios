//
//  RCSCAtMessageUserListViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/25.
//

import UIKit

class RCSCAtMessageUserListViewController: UIViewController {

    
    private lazy var searchBar: RCSCSearchBar = {
        let searchBar = RCSCSearchBar()
        searchBar.searchBarDelegate = userListVC
        return searchBar
    }()
    
    lazy var userListVC = RCSCUserListViewController(communityId: communityId, selectType: .all, cellType: .at)
    
    var delegate: RCSCUserListViewControllerDelegate? {
        didSet {
            userListVC.delegate = delegate
        }
    }
    
    let communityId: String
    
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.height.equalTo(44)
        }
        
        addChild(userListVC)
        view.addSubview(userListVC.view)
        userListVC.view.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(6)
            make.trailing.leading.bottom.equalToSuperview()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
