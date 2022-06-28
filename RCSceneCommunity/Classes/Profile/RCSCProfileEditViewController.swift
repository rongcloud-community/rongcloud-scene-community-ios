//
//  RCSCProfileEditViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/21.
//

import UIKit
import SVProgressHUD

enum RCSCProfileEditItemType {
    case avatar(String?)
    case name(String?)
    case gender(Int?)
}

extension RCSCProfileEditItemType {
    func cell(tableView: UITableView, indexPath: IndexPath, callBack:((String) -> Void)?=nil) -> UITableViewCell {
        switch self {
        case .avatar(let urlStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCProfileEditAvatarCell.reuseIdentifier, for: indexPath) as! RCSCProfileEditAvatarCell
            cell.titleLabel.text = "头像"
            if let urlSr = urlStr {
                cell.imageUrlStr = urlSr
            }
            cell.getImgUrlStrclouse = { urlSr in
//                cell.imageUrlStr = urlStr
                if let callBack = callBack {
                    callBack(urlSr)
                }
            }
            return cell
        case .name(let nameStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCProfileEditNameCell.reuseIdentifier, for: indexPath) as! RCSCProfileEditNameCell
            cell.titleLabel.text = "昵称"
            cell.textField.text = nameStr
            cell.getNameStrclouse = { nameSt in
                if let callBack = callBack {
                    callBack(nameSt)
                }
            }
            return cell
        case .gender(let sexInt):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCProfileEditGenderCell.reuseIdentifier, for: indexPath) as! RCSCProfileEditGenderCell
            cell.titleLabel.text = "性别"
            if let  sexInt = sexInt {
                if sexInt == 1 {
                    cell.maleButton.isSelected = true
                    cell.femaleButton.isSelected = false
                } else if sexInt == 2 {
                    cell.maleButton.isSelected = false
                    cell.femaleButton.isSelected = true
                }
            }
            cell.getSexStrclouse = { sexStr in
                if let callBack = callBack {
                    callBack(sexStr)
                }
            }
            return cell
        }
    }
}

class RCSCProfileEditViewController: UIViewController {
    
    var callBackClouse: (() -> Void)?
    var isNeedRefresh:Bool = false
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(RCSCProfileEditNameCell.self, forCellReuseIdentifier: RCSCProfileEditNameCell.reuseIdentifier)
        tableView.register(RCSCProfileEditAvatarCell.self, forCellReuseIdentifier: RCSCProfileEditAvatarCell.reuseIdentifier)
        tableView.register(RCSCProfileEditGenderCell.self, forCellReuseIdentifier: RCSCProfileEditGenderCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = Asset.Colors.grayEDEDED.color
        tableView.separatorStyle = .none
        return tableView
    }()
    
    var dataSource: Array<RCSCProfileEditItemType> =
    [
     .avatar(RCSCUser.user?.portrait),
     .name(RCSCUser.user?.userName),
     .gender(RCSCUser.user?.sex)
    ]
    var param:[String : Any] = [
        "portrait":RCSCUser.user?.portrait ?? "",
        "sex":RCSCUser.user?.sex ?? 1,
        "userName":RCSCUser.user?.userName ?? ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "个人信息"
        let saveItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveData))
        saveItem.tintColor = Asset.Colors.blue0099FF.color
        navigationItem.rightBarButtonItem = saveItem
        view.backgroundColor = Asset.Colors.blue0099FF.color
        buildSubViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isNeedRefresh {
            if let callBackClouse = callBackClouse {
                callBackClouse()
            }
        }
    }
    private func buildSubViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func saveData() {

        let param = self.param
        RCSCUpdateUserInfoApi.init(userData: param).fetch().success { [weak self] object in
            if let object = object {
                self?.isNeedRefresh = true
                RCSCUser.user?.sex = object.sex
                RCSCUser.user?.userName = object.name
                RCSCUser.user?.portrait = object.portrait
                RCSCUser.user?.rCSCstorageUser()
                SVProgressHUD.showInfo(withStatus: "保存成功")
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }
    func getSaveDataSouce(_ type:RCSCProfileEditItemType) -> String? {
        switch type {
            case .name(let str):
                return str
            case .avatar(let str):
                return str
            case .gender(let intpa):
                if intpa == 1 {
                    return "1"
                } else if intpa == 2 {
                    return "2"
                }
           
        }
        return nil
    }
}

extension RCSCProfileEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 37 : 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 120 : 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = dataSource[indexPath.section]
        
        switch cellType {
            case .avatar:
                let cell = cellType.cell(tableView: tableView, indexPath: indexPath) { [weak self] imgUrlStr in
                    let type = RCSCProfileEditItemType.avatar(imgUrlStr)
                    self?.param["portrait"] = imgUrlStr
                    self?.dataSource[indexPath.section] = type
                    self?.tableView.beginUpdates()
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self?.tableView.endUpdates()
                }
                return cell
            case .name:
                let cell = cellType.cell(tableView: tableView, indexPath: indexPath) { [weak self] nameStr in
                let type = RCSCProfileEditItemType.name(nameStr)
                self?.param["userName"] = nameStr
                self?.dataSource[indexPath.section] = type
                self?.tableView.beginUpdates()
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                self?.tableView.endUpdates()
                }
                return cell
            case .gender:
                let cell = cellType.cell(tableView: tableView, indexPath: indexPath) { [weak self] sexStr in
                let type = RCSCProfileEditItemType.gender(Int(sexStr))
                self?.param["sex"] = Int(sexStr)
                self?.dataSource[indexPath.section] = type
                self?.tableView.beginUpdates()
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                self?.tableView.endUpdates()
                }
                return cell
            }
        
    }
}
