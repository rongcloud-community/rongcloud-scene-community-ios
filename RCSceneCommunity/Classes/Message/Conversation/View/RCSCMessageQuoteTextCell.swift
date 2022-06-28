//
//  RCSCMessageQuoteCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/29.
//

import UIKit

class RCSCMessageQuoteTextCell: RCSCMessageBaseCell {
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.black282828.color
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var quoteIconImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = Asset.Images.messageQuoteIcon.image
        return icon
    }()
    
    private lazy var quoteTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.black282828.color.alpha(0.5)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var quoteContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = Asset.Colors.grayF3F3F3.color
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 8
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .quote
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        
        contentView.addSubview(contentLabel)
        contentLabel.font = .systemFont(ofSize: 18)
        contentLabel.textColor = UIColor(byteRed: 40, green: 40, blue: 40)
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(sendFailView)
        sendFailView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-7)
            make.size.equalTo(CGSize(width: 195, height: 25))
        }
        
        contentView.addSubview(quoteContainerView)
        quoteContainerView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.bottom.equalTo(sendFailView.snp.top).offset(-8)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        quoteContainerView.addSubview(quoteIconImageView)
        quoteIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(Asset.Images.messageQuoteIcon.image.size)
        }
        
        quoteContainerView.addSubview(quoteTextLabel)
        quoteTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalTo(quoteIconImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-6)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let width = layoutAttributes.frame.width
            let size = contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                           withHorizontalFittingPriority: .required,
                                                           verticalFittingPriority: .fittingSizeLevel)
            layoutAttributes.frame.size = CGSize(width: size.width, height: size.height)
            return layoutAttributes
    }
    
    override func updateUI(_ message: RCMessage) -> RCSCCellProtocol {
        super.updateUI(message)
        guard let content = message.content as? RCReferenceMessage,
              let refMsg = content.referMsg as? RCMessageContent,
              let name = refMsg.senderUserInfo.name
        else { return self }
        setContentText(content: content, hasSuffix: message.hasChanged)
        var text = ""
        if let textContent = content.referMsg as? RCTextMessage {
            text = textContent.content ?? ""
        } else if let referContent = content.referMsg as? RCReferenceMessage {
            text = referContent.content ?? ""
        }
        quoteTextLabel.text = "\(name)：\(text)"
        return self
    }
    
    private func setContentText(content: RCReferenceMessage, hasSuffix: Bool) {
        if let text = content.content {
            
            var text = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.black282828.color])
            var suffix = NSAttributedString(string: "（已编辑）", attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.gray8E8E8E.color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
            
            var result = NSMutableAttributedString(attributedString: text)
            
            if hasSuffix {
                result.append(suffix)
            }
            
            contentLabel.attributedText = result
        }
        
    }
    
    override func sendMessageFinished(messageId: Int, code: Int) {
        sendFailView.isHidden = code == RCErrorCode.RC_SUCCESS.rawValue
    }
}

