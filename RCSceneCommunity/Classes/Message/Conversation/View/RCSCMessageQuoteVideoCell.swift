//
//  RCSCMessageQuoteVideoCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/5.
//

import UIKit

class RCSCMessageQuoteVideoCell: RCSCMessageBaseCell {
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
    
    private lazy var quoteNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.black282828.color.alpha(0.5)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var quoteContentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var quoteContainerView: UIView = {
        let container = UIView()
        container.isUserInteractionEnabled = true
        container.backgroundColor = Asset.Colors.grayF3F3F3.color
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 8
        return container
    }()
    
    lazy var playImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Images.messagePlay.image
        return imageView
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
            make.size.equalTo(CGSize(width: 138, height: 102))
        }
        
        quoteContainerView.addSubview(quoteIconImageView)
        quoteIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(Asset.Images.messageQuoteIcon.image.size)
        }
        
        quoteContainerView.addSubview(quoteNameLabel)
        quoteNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalTo(quoteIconImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-6)
        }
        
        quoteContainerView.addSubview(quoteContentImageView)
        quoteContentImageView.snp.makeConstraints { make in
            make.top.equalTo(quoteNameLabel.snp.bottom).offset(8)
            make.leading.equalTo(quoteNameLabel)
            make.size.equalTo(CGSize(width: 72, height: 56))
            make.bottom.equalToSuperview().offset(-14)
        }
        
        quoteContentImageView.addSubview(playImageView)
        playImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: Asset.Images.messagePlay.image.size.width/2, height: Asset.Images.messagePlay.image.size.height/2))
            make.center.equalToSuperview()
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
              let refMsg = content.referMsg as? RCSightMessage,
              let name = refMsg.senderUserInfo.name
        else { return self }
        setContentText(content: content, hasSuffix: message.hasChanged)
        quoteNameLabel.text = "\(name)："
        quoteContentImageView.image = refMsg.thumbnailImage
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
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let message = message,
              let type = type,
              let block = contentTapHandler
        else { return }
        block(message,type,quoteContentImageView)
    }
}
