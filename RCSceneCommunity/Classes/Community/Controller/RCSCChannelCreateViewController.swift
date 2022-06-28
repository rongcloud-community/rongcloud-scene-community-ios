//
//  RCSCChannelCreateViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

import UIKit
import SVProgressHUD

class RCSCChannelCreateViewController: UIViewController {

    private lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        return container
    }()
    
    private lazy var header: RCSCConfirmSaveView = {
        let header = RCSCConfirmSaveView(showBackButton: false)
        header.title = "新建频道"
        header.cancelHandler = { [weak self] in
            if let self = self {
                self.dismiss(animated: true, completion: nil)
            }
        }
        header.saveHandler = { [weak self] in
            guard let self = self,
                  let communityData = self.communityData,
                  let channelName = self.channelName,
                  channelName.count > 0
            else {
                SVProgressHUD.showError(withStatus: "频道昵称不能为空")
                return
            }
            if let maximumNameLength = self.maximumNameLength, channelName.utf16.count > maximumNameLength {
                SVProgressHUD.showError(withStatus: "频道名称应小于16个字符！")
            } else {
                self.dismiss(animated: true, completion: nil)
                RCSCCommunityManager.manager.createChannel(communityId: communityData.uid, groupId: self.groupData.uid, channelName: channelName)
            }
        }
        return header
    }()
    
    private lazy var listView: RCSCChannelCreateListView = {
        let listView = RCSCChannelCreateListView(groupData: groupData)
        listView.categoryDataSource = categoryDataSource
        listView.showSelectGroupViewHandler = { [weak self] in
            //弹出选择群组view
            guard let self = self else { return }
            self.selectGroupView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview()
                make.leading.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        listView.inputTextHandler = { [weak self] text in
            guard let self = self else { return }
            self.channelName = text
        }
        return listView
    }()
    
    private lazy var selectGroupView: RCSCChannelCreateSelectGroupView = {
        let selectGroupView = RCSCChannelCreateSelectGroupView(groupData: groupData)
        selectGroupView.didSelectGroupHandler = { [weak self] data in
            //选择群组
            guard let self = self else { return }
            
            self.selectGroupView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview()
                make.leading.equalTo(self.container.snp.trailing)
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            if let data = data {
                self.listView.reloadData(with: data)
                self.groupData = data
            }
        }
        return selectGroupView
    }()
    
    var categoryDataSource: Array<(selected: Bool, locked: Bool, title: String, subTitle: String, selectedImage: UIImage, normalImage: UIImage)> = [
        (true, false, "文字频道", subTitle: "适用于日常聊天/发布公告", Asset.Images.bigHashtagIcon.image, Asset.Images.bigHashtagIcon.image),
        (false, true, "语音频道", subTitle: "功能还在开发中", Asset.Images.speakerIcon.image, Asset.Images.speakerIcon.image),
        (false, true, "帖子频道", subTitle: "功能还在开发中", Asset.Images.postIcon.image, Asset.Images.postIcon.image)
    ]
    
    var communityData: RCSCCommunityDetailData?
    
    var groupData: RCSCCommunityDetailGroup
    
    var channelName: String?
    
    var maximumNameLength: Int?
    
    init(communityData: RCSCCommunityDetailData?, groupData: RCSCCommunityDetailGroup) {
        self.communityData = communityData
        self.groupData = groupData
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .popover
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildSubViews()
        RCSCKeyboardObserver.registerObserver((inputView: RCSCBox(value:listView.inputView()), contentView: RCSCBox(value: self.view)))
    }
    
    deinit {
        if let inputView = listView.inputView() {
            RCSCKeyboardObserver.unRegisterObserver(inputView: inputView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        guard let _ = container.layer.mask else {
            return container.rcscCorner(corners: [.topLeft, .topRight], radii: 30)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func buildSubViews() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(460)
        }
        
        container.addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        
        container.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        container.addSubview(selectGroupView)
        selectGroupView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.leading.equalTo(container.snp.trailing)
        }
    }
}
