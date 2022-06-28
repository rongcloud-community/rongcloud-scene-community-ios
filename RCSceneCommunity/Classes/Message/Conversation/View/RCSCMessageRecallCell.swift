//
//  RCSCMessageRecallCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/6.
//

import UIKit

class RCSCMessageRecallCell: RCSCMessageBaseCell {
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Asset.Colors.black282828.color.alpha(0.5)
        label.backgroundColor = Asset.Colors.grayF3F3F3.color
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.text = "该消息已撤回"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        type = .text
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 108, height: 34))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateUI(_ message: RCMessage) -> RCSCCellProtocol {
        super.updateUI(message)
        return self
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
       
        let width = layoutAttributes.frame.width
        let size = contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        layoutAttributes.frame.size = CGSize(width: size.width, height: 122)
        return layoutAttributes
    }
}
