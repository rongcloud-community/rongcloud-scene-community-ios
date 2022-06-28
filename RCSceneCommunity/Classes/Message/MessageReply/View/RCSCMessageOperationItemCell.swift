//
//  RCSCMessageOperationItemCell.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/15.
//

import UIKit

class RCSCMessageOperationItemCell: UICollectionViewCell {
    
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 5.5
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(white: 233 / 255.0, alpha: 1).cgColor
        contentView.backgroundColor = UIColor(white: 245 / 255.0, alpha: 1)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(2 / 3.0)
            make.width.height.equalTo(42)
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(white: 135 / 255.0, alpha: 1)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func update(_ operation: RCSCMessageOperation) -> RCSCMessageOperationItemCell {
        imageView.image = operation.image
        titleLabel.text = operation.title
        return self
    }
}

