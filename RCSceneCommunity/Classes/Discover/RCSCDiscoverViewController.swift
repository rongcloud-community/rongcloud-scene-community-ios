//
//  RCSCDiscoverViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/22.
//

import UIKit
import SVProgressHUD
let RCSCDiscoverViewControllerAddTmpCommunityNotification = Notification.Name(rawValue: "RCSCDiscoverViewControllerAddTmpCommunityNotification")

public class RCSCDiscoverViewController: RCSCBaseViewController {
    
    private lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.text = "发现社区"
        
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(27)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        return headerView
    }()
    
    lazy var refreshHeader: MJRefreshNormalHeader = {
        let header = MJRefreshNormalHeader()
        header.isHidden = false
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        return header
    }()
    
    @objc private func refresh() {
        fetchDiscoverData()
    }
    
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (kScreenWidth - 40)/2, height: 205)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(RCSCDiscoverCell.self, forCellWithReuseIdentifier: RCSCDiscoverCell.reuseIdentifier)
        collectionView.backgroundView = emptyView
        collectionView.mj_header = refreshHeader
        return collectionView
    }()
    
    private lazy var emptyView: UIView = {
        
        let emptyView = UIView()
        
        emptyView.backgroundColor = .white
        
        let iconView = UIImageView(image: Asset.Images.discoverEmptyIcon.image)
        emptyView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.size.equalTo(CGSize(width: 54, height: 46))
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black.alpha(0.4)
        titleLabel.text = "暂未发现社区"
        emptyView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(4)
            make.centerX.equalTo(iconView)
        }
        
        emptyView.isHidden = true
        
        return emptyView
    }()
    
    var dataSource = Array<RCSCDiscoverListRecord>()
    
    let net = RCSCNetworkReachabilityManager()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        RCSCDiscoverService.service.registerListener(listener: self)
        view.backgroundColor = .white
        buildSubViews()
        net?.startListening(onUpdatePerforming: {[weak self] status in
            guard let self = self else { return }
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self.refreshHeader.beginRefreshing()
                break
            default:
                break
            }
        })
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshHeader.beginRefreshing()
    }
 
    private func buildSubViews() {
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(96)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.bottom.equalToSuperview() //.offset(-UIDevice.vg_tabBarFullHeight())
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    private func fetchDiscoverData() {
        RCSCDiscoverService.service.fetchDiscoverList(pageNum: 0, pageSize: 1000)
    }
}

extension RCSCDiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = dataSource.count
        emptyView.isHidden = itemCount != 0
        return itemCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RCSCDiscoverCell.reuseIdentifier, for: indexPath) as! RCSCDiscoverCell
        let data = dataSource[indexPath.row]
        cell.data = data
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        SVProgressHUD.show()
        RCSCCommunityDetailApi(communityId: data.communityUid).fetch().success { object in
            SVProgressHUD.dismiss()
            DispatchQueue.main.async {
                RCSCCommunityManager.manager.needJumpToDefaultChannel = true
                NotificationCenter.default.post(name: RCSCDiscoverViewControllerAddTmpCommunityNotification, object: data)
            }
        }.failed { error in
            if error.code == 10001 {
                SVProgressHUD.showError(withStatus:"当前社区已解散")
                DispatchQueue.main.async {
                    self.refreshHeader.beginRefreshing()
                }
            } else {
                SVProgressHUD.showError(withStatus:"网络错误")
            }
        }

    }
}

extension RCSCDiscoverViewController: RCSCDiscoverServiceDelegate {
    func fetchDiscoverListSuccess(list: Array<RCSCDiscoverListRecord>?) {
        refreshHeader.endRefreshing()
        if let list = list {
            dataSource = list
            collectionView.reloadData()
        }
    }
}
