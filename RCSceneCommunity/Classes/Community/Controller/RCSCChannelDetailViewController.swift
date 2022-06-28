//
//  RCSCChannelDetailViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/23.
//

import UIKit
import SwiftUI
import SVProgressHUD

let RCSCChannelDetailViewControllerModifyChannelNameNotification = Notification.Name(rawValue: "RCSCChannelDetailViewControllerModifyChannelNameNotification")

let RCSCChannelIdKey = "RCSCChannelDetailViewControllerModifyChannelNameNotificationId"
let RCSCChannelTextKey = "RCSCChannelDetailViewControllerModifyChannelNameNotificationText"
let RCSCChannelTypeKey = "RCSCChannelDetailViewControllerModifyChannelNameNotificationType"

struct RCSCChannelDetailModel {
    let title: String
    let subTitles: Array<String>
    let action:(()->Void)
}

class RCSCChannelDetailViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCArrowCell.self, forCellReuseIdentifier: RCSCArrowCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = Asset.Colors.grayEDEDED.color
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 40
        return tableView
    }()
    
    var dataSource = Array<Array<RCSCChannelDetailModel>>()
    
    let communityId: String
    let channelId: String
    var isCreator = false
    
    init(communityId:String, channelId: String) {
        self.communityId = communityId
        self.channelId = channelId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "频道详情"
        buildSubViews()
        fetchChannelDetail()
    }
    
    private func fetchChannelDetail() {
        RCSCChannelDetailApi(channelId: channelId).fetch().success {[weak self] object in
            guard let self = self else { return }
            guard let object = object else { return }
            self.reloadData(with: object)
        }.failed { error in
            SVProgressHUD.showError(withStatus: "\(error.desc)")
        }
    }
    
    private func buildSubViews() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateChannelDetail(type: RCSCIntroViewControllerOperateType, text: String, channelOriginalDetail: RCSCChannelDetailData) {
        var channelDetail: RCSCChannelDetailData?
        if type == .channelName {
            channelDetail = RCSCChannelDetailData(name: text, remark: channelOriginalDetail.remark, uid: channelOriginalDetail.uid)
        } else {
            channelDetail = RCSCChannelDetailData(name: channelOriginalDetail.name, remark: text, uid: channelOriginalDetail.uid)
        }
        reloadData(with: channelDetail!)
        NotificationCenter.default.post(name: RCSCChannelDetailViewControllerModifyChannelNameNotification, object: nil, userInfo: [RCSCChannelIdKey : channelDetail!.uid,
                                                                                                                                   RCSCChannelTextKey: text,
                                                                                                                                   RCSCChannelTypeKey: type])
    }
    
    func pushTextEditViewController(type: RCSCIntroViewControllerOperateType, channelDetail: RCSCChannelDetailData) {
        let textEditViewController = RCSCIntroViewController(intro: type == .channelName ? channelDetail.name : channelDetail.remark, title: type == .channelName ? "频道名称" : "频道简介", type:type)
        textEditViewController.limit = type == .channelName ? 16 : 200
        textEditViewController.channelId = channelId //修改频道相关信息需要channelId
        textEditViewController.needRefreshDetail = { [weak self] text in
            guard let self = self else { return }
            self.updateChannelDetail(type: type, text: text, channelOriginalDetail: channelDetail)
        }
        navigationController?.pushViewController(textEditViewController, animated: true)
    }
    
    func pushMarkMessageViewController() {
        guard let viewControllers = navigationController?.viewControllers else { return }
        for viewController in viewControllers {
            if let conversationViewController = viewController as? RCSCConversationViewController {
                let markMessageVC = RCSCMarkMessageViewController(communityId: communityId, channelId: channelId)
                markMessageVC.isCreator = isCreator
                markMessageVC.jumpToMessage = { markMessage in
                    conversationViewController.jumpToMessage(messageUid: markMessage.messageUid)
                }
                self.navigationController?.pushViewController(markMessageVC, animated: true)
            }
        }
    }
    func reloadData(with channelDetail: RCSCChannelDetailData) {
        dataSource = [
           [
            RCSCChannelDetailModel(title: "频道名称",subTitles: [channelDetail.name],action: { [weak self] in
                guard let self = self else { return }
                self.pushTextEditViewController(type: .channelName, channelDetail: channelDetail)
            })
           ],
           [
            RCSCChannelDetailModel(title: "频道简介",subTitles: [channelDetail.remark.count == 0 ? "现在还没有简介，请编辑" : channelDetail.remark],action: { [weak self] in
                guard let self = self else { return }
                self.pushTextEditViewController(type: .channelRemark, channelDetail: channelDetail)
            }),
           ],
           [
            RCSCChannelDetailModel(title: "",subTitles: ["已标注消息"],action: { [weak self] in
                guard let self = self else { return }
                self.pushMarkMessageViewController()
            })
           ]
        ]
        tableView.reloadData()
        
    }
}

extension RCSCChannelDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCArrowCell.reuseIdentifier, for: indexPath) as! RCSCArrowCell
        cell.text = dataSource[indexPath.section][0].subTitles[0]
        return  cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 26 : 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return RCSCSectionTextHeader(text:dataSource[section][0].title)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.section][0]
        model.action()
    }
}

