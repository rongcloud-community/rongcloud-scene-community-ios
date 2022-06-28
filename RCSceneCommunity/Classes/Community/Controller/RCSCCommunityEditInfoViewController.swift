//
//  RCSCCommunityEditInfoViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/25.
//

import UIKit
import SVProgressHUD
//import SwiftUI

let RCSCCommunityEditInfoImageNotification = Notification.Name(rawValue: "RCSCCommunityEditInfoImageNotification")
let RCSCCommunityEditInfoImageIDKey = "communityId"
let RCSCCommunityEditInfoImageURLKey = "url"
let RCSCCommunityEditInfoImageTypeKey = "type"

enum RCSCCommunityEditInfoActionType {
    case name(String?)
    case avatar(String?)
    case cover(String?)
    case intro(String?)
    case defaultChannel(String?)
    case defaultNotifySetting(String?)
    case systemMessageChannel(String?)
}

private extension RCSCCommunityEditInfoActionType {
  
    func cell(tableView: UITableView, indexPath: IndexPath) -> RCSCArrowCell {
        switch self {
        case  .name(let textStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoTextCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoTextCell
            cell.text = title
            cell.editTextLabel.text = textStr  //text
            return cell
        case .avatar(let urlStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoImageCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoImageCell
            cell.text = title
            cell.editImageView.setImage(with: urlStr ?? "")
            cell.radius = 20
            return cell
        case .cover(let urlStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoImageCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoImageCell
            cell.text = title
            cell.editImageView.setImage(with: urlStr ?? "")  //image = UIImage.init(named: urlStr ?? "") // image
            cell.radius = 4
            return cell
        case .intro(let textStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoTextCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoTextCell
            cell.text = title
            cell.editTextLabel.text = textStr //text
            return cell
        case .defaultChannel(let textStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoDescCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoDescCell
            cell.text = title
            cell.editTextLabel.text = textStr //text
            cell.editDescLabel.text = desc //desc
            return cell
        case .defaultNotifySetting(let textStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoDescCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoDescCell
            cell.text = title
            cell.editTextLabel.text = textStr //text
            cell.editDescLabel.text =  desc
            //SDK获取当前社区默认设置
            let communityId = RCSCCommunityManager.manager.currentDetail.uid
            RCSCConversationMessageManager.getCommunityDefaultNotificationType(communityId: communityId) { level in
                DispatchQueue.main.async {
                    switch level {
                    case .allMessage:
                        cell.editTextLabel.text = "所有消息都通知"
                    case .mention:
                        cell.editTextLabel.text = "仅被@时通知"
                    default:
                        RCSCConversationMessageManager.setCommunityDefaultNotificationType(communityId: communityId, level: .allMessage) {
                        } error: { code in
                        }
                    }
                }
            } error: { code in
                debugPrint("get notification default setting failed code: \(code.rawValue)")
            }

            return cell
        case .systemMessageChannel(let textStr):
            let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityEditInfoDescCell.reuseIdentifier, for: indexPath) as! RCSCCommunityEditInfoDescCell
            cell.text = title
            cell.editTextLabel.text = textStr //text
            cell.editDescLabel.text = desc
            return cell
        }
    }
    var title: String {
        get {
            switch self {
            case .name:
                return "社区名称"
            case .avatar:
                return "社区头像"
            case .cover:
                return "社区封面"
            case .intro:
                return "社区简介"
            case .defaultChannel:
                return "默认进入频道"
            case .defaultNotifySetting:
                return "默认通知设置"
            case .systemMessageChannel:
                return "系统消息频道"
            }
        }
    }
 
    var text: String? {
        get {
            switch self {
            case .name:
                return "mc的小卖铺"
            case .intro:
                return "小卖铺里应有尽有..."
            case .defaultChannel:
                return "公告和规则"
            case .defaultNotifySetting:
                return "所有消息都通知"
            case .systemMessageChannel:
                return "日常聊天"
            default:
                return nil
            }
        
        }
        set {
//            guard let newText = newValue else { return }
            
        }
    }
    
    var image: UIImage? {
        get {
            switch self {
            case .name:
                return nil
            case .avatar:
                return nil
            default:
                return nil
            }
        }
        set {
           
        }
    }
    
    var desc: String? {
        get {
            switch self {
            case .defaultChannel:
                return "新用户进入社区时默认访问的频道"
            case .defaultNotifySetting:
                return "新用户进入社区时默认消息通知方式"
            case .systemMessageChannel:
                return "接收新用户加入社区等系统消息"
            default:
                return nil
            }
        }
        set {
           
        }
    }
}

//private var communityEditInfoViewDetail = RCSCCommunityManager.manager.currentDetail
class RCSCCommunityEditInfoViewController: UIViewController {
    public var communityId: String?
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCCommunityEditInfoTextCell.self, forCellReuseIdentifier: RCSCCommunityEditInfoTextCell.reuseIdentifier)
        tableView.register(RCSCCommunityEditInfoImageCell.self, forCellReuseIdentifier: RCSCCommunityEditInfoImageCell.reuseIdentifier)
        tableView.register(RCSCCommunityEditInfoDescCell.self, forCellReuseIdentifier: RCSCCommunityEditInfoDescCell.reuseIdentifier)
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
   
    static var recordPhotoIndex: IndexPath?
    static var recordUrlPathStr: String?
    var dataSource: Array<Array<RCSCCommunityEditInfoActionType>> =
    [
        [.name(RCSCCommunityManager.manager.currentDetail.name),
         .avatar(RCSCCommunityManager.manager.currentDetail.portrait),
         .cover(RCSCCommunityManager.manager.currentDetail.coverUrl),
         .intro(RCSCCommunityManager.manager.currentDetail.remark)],
        [.defaultChannel(getDefaultChannelStr()),
         .defaultNotifySetting(getDefaultNotifySettingStr()),
         .systemMessageChannel(getSystemMessageChannelStr())]
    ]
    
    
   static func getDefaultChannelStr() -> String {
       //[RCSCCommunityDetailChannel]
        let tempStr = RCSCCommunityManager.manager.currentDetail.joinChannelUid
 
//       let str: String
       for1: for group in RCSCCommunityManager.manager.currentDetail.groupList {
            for2: for channel in group.channelList {
                   if tempStr == channel.uid {
                       return channel.name
                   }
               }
           }
       return ""
    }
    
    static func getDefaultNotifySettingStr() -> String {
        //"noticeType": 用户群通知设置,0:所有消息都接收,1:被@时通知，2:从不通知
         let str: String
        switch RCSCCommunityManager.manager.currentDetail.noticeType {
        case .all:
            str = "所有消息都接收"
        case .at:
            str = "被@时通知"
        case .never:
            str = "从不通知"
        default:
            str = "所有消息都接收"
        }
         return str
     }
     
    static func getSystemMessageChannelStr() -> String {

        let tempStr = RCSCCommunityManager.manager.currentDetail.msgChannelUid
 
        for1: for group in RCSCCommunityManager.manager.currentDetail.groupList {
            for2: for channel in group.channelList {
                   if tempStr == channel.uid {
                       return channel.name
                   }
               }
           }
        return ""
     }
    
    deinit {
        Self.recordPhotoIndex = nil
        Self.recordUrlPathStr = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RCSCCommunityManager.manager.registerListener(listener: self)
        title = "编辑资料"
        view.backgroundColor = .white
        buildSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func buildSubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension RCSCCommunityEditInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 48 : 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.section][indexPath.row]
        return type.cell(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var type = dataSource[indexPath.section][indexPath.row]
        var vc: UIViewController?
        switch type {
        case .name:
            vc = RCSCCommunityEditNameViewController(communityDetail: RCSCCommunityManager.manager.currentDetail)
            let tempVc = vc as! RCSCCommunityEditNameViewController
            tempVc.needRefreshDetail = { [weak self] namesStr in
                guard let self = self else { return  }
                RCSCCommunityManager.manager.currentDetail.name = namesStr
                type = RCSCCommunityEditInfoActionType.name(namesStr)
                self.dataSource[indexPath.section][indexPath.row] = type
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            vc = tempVc
            
            break
        case .avatar:
            selectImage(indexPath)
            break
        case .cover:
            selectImage(indexPath)
            break
        case .intro:
            let editIntroVC = RCSCIntroViewController(intro: RCSCCommunityManager.manager.currentDetail.remark , title: "社区简介", type: .communityRemark)
            editIntroVC.limit = 200
            editIntroVC.needRefreshDetail = { [weak self] namesStr in
                guard let self = self else { return  }
                RCSCCommunityManager.manager.currentDetail.remark = namesStr
                type = RCSCCommunityEditInfoActionType.intro(namesStr)
                self.dataSource[indexPath.section][indexPath.row] = type
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            vc = editIntroVC
            break
        case .defaultChannel:
            vc = RCSCChannelSelectViewController(.formDefaultChannel)
            let tempVc = vc as! RCSCChannelSelectViewController
            tempVc.needRefreshDetail = { [weak self] namesStr in
                guard let self = self else { return  }
                type = RCSCCommunityEditInfoActionType.defaultChannel(namesStr)
                self.dataSource[indexPath.section][indexPath.row] = type
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            vc = tempVc
            
            break
        case .defaultNotifySetting:
            vc = RCSCCommunityNotifySettingViewController(communityDetail: RCSCCommunityManager.manager.currentDetail, title: "默认通知设置", desc: "新用户进入社区时的默认消息通知方式", style: .info)
            let tempVc = vc as! RCSCCommunityNotifySettingViewController
            vc = tempVc
            break
        case .systemMessageChannel:
            vc = RCSCChannelSelectViewController(.fromSystemMessageChannel)
            let tempVc = vc as! RCSCChannelSelectViewController
            tempVc.needRefreshDetail = { [weak self] namesStr in
                guard let self = self else { return  }
                type = RCSCCommunityEditInfoActionType.systemMessageChannel(namesStr)
                self.dataSource[indexPath.section][indexPath.row] = type
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            vc = tempVc
            break
        }
        
        guard let vc = vc else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func selectImage(_ indexPath: IndexPath) {
        SVProgressHUD.show(withStatus: "唤起相册功能请中...")

        RCSCImagePickerController.showImagePicker(in: self, imageSelectedCompletionClosure: { [weak self] image in
            SVProgressHUD.dismiss()
            defer {
                self?.dismiss(animated: true, completion: nil)
            }
            guard let self = self,
                  let image = image,
                  let data = image.jpegData(compressionQuality: 0.5)
            else { return }
            RCSCUploadApi().uploadImage(data: data).success { object in
                if let path = object {
                    self.updateCommunityPhoto(path,indexPath)
                } else {
                    SVProgressHUD.showError(withStatus: "图片上传失败")
                }

            }
        }, videoSelectedCompletionClosure: nil) {
            SVProgressHUD.dismiss()
        }
    }
}

extension RCSCCommunityEditInfoViewController: RCSCCommunityDataSourceDelegate{
    
    func updateCommunityInfo(_ isSuccess: Bool){
        SVProgressHUD.dismiss()
        if isSuccess {
            guard let indexPath = Self.recordPhotoIndex , let path = Self.recordUrlPathStr
            else { return }
            
            var type = self.dataSource[indexPath.section][indexPath.row]
            switch type {
            case .cover(var urlStr):
                urlStr = "\(path)"
                RCSCCommunityManager.manager.currentDetail.coverUrl = urlStr!
                type = RCSCCommunityEditInfoActionType.cover(urlStr)
                SVProgressHUD.showSuccess(withStatus: "社区头像更新成功")
            case .avatar(var urlStr):
                urlStr = "\(path)"
                RCSCCommunityManager.manager.currentDetail.portrait = urlStr!
                type = RCSCCommunityEditInfoActionType.avatar(urlStr)
                SVProgressHUD.showSuccess(withStatus: "社区封面更新成功")
            default:
                print("待扩展")
                break
            }
            
            self.dataSource[indexPath.section][indexPath.row] = type
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }        
    }
    func updateCommunityPhoto(_ path: String, _ indexPath: IndexPath) {
        let type = self.dataSource[indexPath.section][indexPath.row]
        var url = ""
        var notificationType = 0
        switch type {
        case .cover(var urlStr):
            urlStr = "\(kHost)/file/show?path=\(path)"
            url = urlStr!
            Self.recordPhotoIndex = indexPath
            Self.recordUrlPathStr = urlStr!
            SVProgressHUD.show()
            notificationType = 1
            RCSCCommunityManager.manager.updateCommunity(communityId: RCSCCommunityManager.manager.currentDetail.uid, param: ["coverUrl":urlStr!])
        case .avatar(var urlStr):
            urlStr = "\(kHost)/file/show?path=\(path)"
            url = urlStr!
            Self.recordUrlPathStr = urlStr!
            Self.recordPhotoIndex = indexPath
            SVProgressHUD.show()
            notificationType = 0
            RCSCCommunityManager.manager.updateCommunity(communityId: RCSCCommunityManager.manager.currentDetail.uid, param: ["portrait":urlStr!])
        default:
            print("待扩展")
            break
        }
    
        NotificationCenter.default.post(name: RCSCCommunityEditInfoImageNotification, object: nil, userInfo: [RCSCCommunityEditInfoImageURLKey: url, RCSCCommunityEditInfoImageTypeKey: notificationType, RCSCCommunityEditInfoImageIDKey: communityId])
    }
}
