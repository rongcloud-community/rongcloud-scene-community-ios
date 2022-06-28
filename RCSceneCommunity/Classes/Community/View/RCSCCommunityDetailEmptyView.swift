//
//  RCSCChannelListEmptyView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/10.
//

import UIKit

typealias RCSCCommunityDetailEmptyViewAction = () -> Void

class RCSCCommunityDetailEmptyView: UIView {

    private func createButton(_ image: UIImage, _ title: String, _ selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 27
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    private lazy var createButton: UIButton = {
        return createButton(Asset.Images.createCommunityIcon.image, "创建社区", #selector(createGroup))
    }()
    
    private lazy var discoverButton: UIButton = {
        return createButton(Asset.Images.discoverIcon.image, "发现社区", #selector(discoverGroup))
    }()
    
    var createGroupHandler: RCSCCommunityDetailEmptyViewAction?
    
    var discoverGroupHandler: RCSCCommunityDetailEmptyViewAction?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(106) // tableview contentinset.top = 76
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(54)
        }
        
        addSubview(discoverButton)
        discoverButton.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(54)
        }
    }
    
    @objc private func createGroup() {
        if let block = createGroupHandler {
            block()
        }
    }
    
    @objc private  func discoverGroup() {
        if let block = discoverGroupHandler {
            block()
        }
    }
}
