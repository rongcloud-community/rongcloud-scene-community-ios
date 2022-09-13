//
//  RCSCMessageTextCell.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/9.
//

import UIKit

class RCSCMessageTextCell: RCSCMessageBaseCell {
    private lazy var contentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .text
        contentView.addSubview(sendFailView)
        sendFailView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-7)
            make.size.equalTo(CGSize(width: 195, height: 25))
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.font = .systemFont(ofSize: 18)
        contentLabel.textColor = UIColor(byteRed: 40, green: 40, blue: 40)
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(sendFailView.snp.top).offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        guard
            let content = message.content as? RCTextMessage
        else { return self }
        
        setContentText(content: content, hasSuffix: message.hasChanged)
        
        if message.canIncludeExpansion, let dict = message.expansionDic ,let string = dict[kConversationAtMessageTypeKey] {
            setAttrText(jsonString: string, text: content.content, hasSuffix: message.hasChanged)
        }
        
        return self
    }
    
    private func setContentText(content: RCTextMessage, hasSuffix: Bool) {
        let text = content.content
        if text.count > 0 {
            
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
    
    func setAttrText(jsonString: String, text: String, hasSuffix: Bool) {
        if let dict = jsonString.getDictionary(), let names = dict.allValues as? Array<String> {
            let ranges = atNickNameRanges(users: names, text: text)
            let attr = NSMutableAttributedString(string: text)
            attr.addAttributes([.foregroundColor: UIColor(byteRed: 40, green: 40, blue: 40)], range: NSRange(location: 0, length: text.count))
            guard let ranges = ranges else { return }
            for range in ranges {
                attr.addAttributes([.foregroundColor: Asset.Colors.blue0099FF.color], range: NSRange(location: range.location, length: range.length - 1))
            }
            if (hasSuffix) {
                let suffix = NSAttributedString(string: "（已编辑）", attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.gray8E8E8E.color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                attr.append(suffix)
            }
            contentLabel.attributedText = attr
        }
    }
    
    func atNickNameRanges(users: Array<String>, text: String) -> Array<NSRange>? {
        var ranges = Array<NSRange>()
        for user in users {
            ranges = ranges + text.getNSRanges(string: "@\(user) ")
        }
        if ranges.count == 1 { return ranges }
        return ranges
    }
}


