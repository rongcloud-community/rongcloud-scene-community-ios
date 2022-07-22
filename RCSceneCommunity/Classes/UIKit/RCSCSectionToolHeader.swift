//
//  RCSCSectionToolHeader.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/8.
//

import UIKit

typealias RCSCSectionToolHeaderClick = (Int) -> Void

class RCSCSectionToolHeader: UIView {
    
    var section = 0
    
    var on: Bool? {
        willSet {
            if openEnable {
                if let value = newValue {
                    openButton.setImage(value ? Asset.Images.channelOpenIcon.image : Asset.Images.channelCloseIcon.image, for: .normal)
                }
            }
        }
    }
    
    var disableCreate: Bool = false {
        willSet {
            addButton.isHidden = newValue
        }
    }
    
    var hideCreateChannelButton: Bool = true {
        didSet {
            addButton.isHidden = hideCreateChannelButton
        }
    }
    
    var groupOpenHandler: RCSCSectionToolHeaderClick?
    
    var groupCreateHandler: RCSCSectionToolHeaderClick?
    
    var sectionName: String? {
        willSet {
            if let text = newValue {
                label.text = text
            }
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.grayC4C4C4.color
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.isUserInteractionEnabled = true
        return label
    }()

    private lazy var openButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(Asset.Images.channelCloseIcon.image, for: .normal)
        btn.addTarget(self, action: #selector(open(sender:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = disableCreate
        btn.isHidden = hideCreateChannelButton
        btn.setImage(Asset.Images.channelGroupAddIcon.image, for: .normal)
        btn.addTarget(self, action: #selector(create(sender:)), for: .touchUpInside)
        return btn
    }()
    
    let openEnable: Bool
    
    init(openEnable: Bool) {
        self.openEnable = openEnable
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        backgroundColor = Asset.Colors.grayF6F6F6.color
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        addSubview(openButton)
        openButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 34, height: 34))
            make.leading.equalToSuperview().offset(11)
        }
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(openButton.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(openButton)
            make.size.equalTo(openButton)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    @objc func open(sender: UIButton) {
        if let block = groupOpenHandler {
            block(section)
        }
    }
    
    @objc func create(sender: UIButton) {
        if let block = groupCreateHandler {
            block(section)
        }
    }
}
