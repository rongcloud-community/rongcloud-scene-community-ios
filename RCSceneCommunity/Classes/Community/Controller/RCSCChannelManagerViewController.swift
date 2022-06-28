//
//  RCSCChannelManagerViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/15.
//

import UIKit

extension RCSCChannelManagerListStyle{
    var title: String {
        switch self {
        case .channel:
            return "频道管理"
        case .group:
            return "分组管理"
        }
    }
}

class RCSCChannelManagerViewController: UIViewController {

    private lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        return container
    }()
    
    private lazy var header: RCSCConfirmSaveView = {
        let header = RCSCConfirmSaveView(showBackButton: false)
        header.title = self.style.title
        header.cancelHandler = { [weak self] in
            if let self = self {
                self.dismiss(animated: true, completion: nil)
            }
        }
        header.saveHandler = { [weak self] in
            if let self = self {
                var communityDetail = RCSCCommunityManager.manager.currentDetail
                communityDetail.groupList = self.listView.groupList
                if let communityDetailDictionary = communityDetail.convertToDict() {
                    RCSCCommunityManager.manager.saveCommunityDetail(communityDetailDictionary: communityDetailDictionary, updateType: self.style.updateType())
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        return header
    }()
    
    private lazy var listView: RCSCChannelManagerListView = {
        let listView = RCSCChannelManagerListView(type: style)
        listView.beginEdit = { inputView in 
            RCSCKeyboardObserver.registerObserver((inputView: RCSCBox(value:inputView), contentView: RCSCBox(value: self.view)))
        }
        listView.endEdit = { inputView in
            RCSCKeyboardObserver.unRegisterObserver(inputView: inputView)
        }
        return listView
    }()
    
    let style: RCSCChannelManagerListStyle
    
    init(style: RCSCChannelManagerListStyle) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildSubViews()
    }
    
    override func viewDidLayoutSubviews() {
        guard let _ = container.layer.mask else {
            return container.rcscCorner(corners: [.topLeft, .topRight], radii: 30)
        }
    }
    
    private func buildSubViews() {
        
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(508)
        }
        
        container.addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        
        container.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
