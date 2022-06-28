//
//  RCSCConversationEmptyView.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/17.
//

import UIKit

class RCSCConversationEmptyView: UIView {

    private lazy var imageView = UIImageView(image: Asset.Images.coversationEmpty.image)
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.text = "来都来了，聊几句再走"
        instance.textColor = .black.alpha(0.4)
        instance.font = .systemFont(ofSize: 16)
        return instance
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(62)
            make.height.equalTo(48.5)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
