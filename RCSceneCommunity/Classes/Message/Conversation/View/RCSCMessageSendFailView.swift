//
//  RCSCMessageSendFailView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/25.
//

import UIKit

class RCSCMessageSendFailView: UIView {

    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.image = Asset.Images.messageSendFail.image
        return iconView
    }()
    
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = Asset.Colors.black282828.color
        messageLabel.text = "消息发送失败"
        return messageLabel
    }()
    
    private lazy var resendButton: UIButton = {
        let resendButton = UIButton(type: .custom)
        resendButton.setTitle("重新发送", for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        resendButton.setTitleColor(Asset.Colors.blue0099FF.color, for: .normal)
        resendButton.addTarget(self, action: #selector(resend), for: .touchUpInside)
        return resendButton
    }()
    
    var resendHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        
        backgroundColor = Asset.Colors.black838383.color.alpha(0.2)
        
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
        }
        
        addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(2)
            make.trailing.equalTo(resendButton.snp.leading).offset(-2)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func resend() {
        if let block = resendHandler {
            block()
        }
    }
}
