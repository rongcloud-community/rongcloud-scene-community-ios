//
//  RCSCProfileViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/18.
//

import UIKit
import SVProgressHUD

enum RCSCProfileItemType {
    case terms
    case privacyPolicy
    case deleteAccount
    case logout
}

private extension RCSCProfileItemType {
    func title() -> String {
        switch self {
        case .terms:
            return "注册条款"
        case .privacyPolicy:
            return "隐私协议"
        case .deleteAccount:
            return "注销账号"
        case .logout:
            return "退出登录"
        }
    }
    
    func cellStyle() -> RCSCProfileCellStyle {
        switch self {
        case .terms:
            return .arrow
        case .privacyPolicy:
            return .arrow
        case .deleteAccount:
            return .normal
        case .logout:
            return .normal
        }
    }
    
    func textColor() -> UIColor {
        switch self {
        case .terms:
            return Asset.Colors.black949494.color
        case .privacyPolicy:
            return Asset.Colors.black949494.color
        case .deleteAccount:
            return Asset.Colors.redD96565.color
        case .logout:
            return Asset.Colors.redD96565.color
        }
    }
}

open class RCSCProfileViewController: RCSCBaseViewController {

    private lazy var header: RCSCProfileHeaderView = {
        let header = RCSCProfileHeaderView()
        header.editProfileHandler = { [weak self] in
            guard let self = self else { return }
            let vc = RCSCProfileEditViewController()
            vc.callBackClouse = {
                self.reloadHeader()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return header
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(RCSCProfileCell.self, forCellReuseIdentifier: RCSCProfileCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Asset.Colors.grayEDEDED.color
        tableView.separatorColor = Asset.Colors.grayC8CCD4.color
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        return tableView
    }()
    
    let dataSource:Array<Array<RCSCProfileItemType>> = [[.terms,.privacyPolicy],[.deleteAccount,.logout]]
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.delegate = self
        buildSubViews()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    private func buildSubViews() {
        
        if kScreenWidth < 375 { // 4寸的手机
            header.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 300*kScreenWidth/375)
            header.clipsToBounds = true
            tableView.tableHeaderView = header
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
            }
            tableView.isScrollEnabled = true
            tableView.bounces = false
            
        }else {
            view.addSubview(header)
            header.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(300)
            }
            
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(header.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }

    }
   
    public func reloadHeader() {
        guard let _ = RCSCUser.RCSCGetUser() else { return  }
        header.refresh()
    }
    open func logout(){
        RCSCUser.clearRCSCUserData()
    }
}

extension RCSCProfileViewController: UITableViewDelegate,UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCProfileCell.reuseIdentifier, for: indexPath) as! RCSCProfileCell
        let cellType = dataSource[indexPath.section][indexPath.row]
        cell.cellStyle = cellType.cellStyle()
        cell.titleLabel.text = cellType.title()
        cell.textColor = cellType.textColor()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = dataSource[indexPath.section][indexPath.row]
        switch cellType {
            case .terms:
                termsClick(cellType)
            case .privacyPolicy:
                privacyPolicyclick(cellType)
            case .deleteAccount:
                deleteAccountClick (cellType)
            case .logout:
                logoutClick(cellType)
        }
    }
    
}


extension RCSCProfileViewController {
    //注册条款
    func termsClick(_ cellType:RCSCProfileItemType) {
        //FIXME: url暂时与RCE 一致,后期再对齐
        let urlStr = "https://cdn.ronghub.com/term_of_service_zh.html"
        let wkWebVc = RCSCWKWebVC.init(cellType.title(), url: urlStr)
        self.navigationController?.pushViewController(wkWebVc, animated: true)
    }
    // 隐私协议
    func privacyPolicyclick(_ cellType:RCSCProfileItemType) {
        //FIXME: url暂时与RCE 一致,后期再对齐
        let urlStr = "https://cdn.ronghub.com/Privacy_agreement_zh.html"
        let wkWebVc = RCSCWKWebVC.init(cellType.title(), url: urlStr)
        self.navigationController?.pushViewController(wkWebVc, animated: true)
    }
    // 注销
    func deleteAccountClick (_ cellType:RCSCProfileItemType) {
        showResignAlert(cellType)
    }
    func logoutClick(_ cellType:RCSCProfileItemType = .logout){
        //FIXME: wait for 后台接口
        logout()
//        SVProgressHUD.showInfo(withStatus: cellType.title())
    }
    
    private func showResignAlert(_ cellType:RCSCProfileItemType) {
        let vc = UIAlertController(title: "注销用户？", message: "注销用户会导致您创建的账户和相关信息从服务器彻底移除，是否确认注销用户？", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.resign(cellType)
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        present(vc, animated: true, completion: nil)
    }
    
    private func resign(_ cellType:RCSCProfileItemType){
        SVProgressHUD.show(withStatus: "\(cellType.title())网络请求中...")
        RCSCResignOutApi.init().fetch().success { [weak self] object in
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "\(cellType.title()): 成功")
            self?.logoutClick()
        }.failed { error in
            SVProgressHUD.dismiss()
            let errorMsg = "\(error.desc)：\(error.code)"
            SVProgressHUD.showError(withStatus: errorMsg)
        }
    }
}
