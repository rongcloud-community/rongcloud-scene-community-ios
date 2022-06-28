//
//  RCSCCommunityEditInfoImageCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/25.
//

import UIKit

class RCSCCommunityEditInfoImageCell: RCSCArrowCell {
    
    lazy var editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Asset.Colors.blue0099FF.color
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = radius
        return imageView
    }()

    override class var reuseIdentifier: String {
        get {
            return String(describing: RCSCCommunityEditInfoImageCell.self)
        }
    }
    
    var radius: CGFloat  = 4 {
        willSet {
            editImageView.layer.cornerRadius = newValue
        }
    }
    
    override func buildSubViews() {
        super.buildSubViews()
        contentView.addSubview(editImageView)
        editImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowView.snp.leading).offset(-10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
}
