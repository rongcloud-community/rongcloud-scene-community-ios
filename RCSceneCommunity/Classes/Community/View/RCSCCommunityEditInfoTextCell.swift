//
//  RCSCCommunityEditInfoTextCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/25.
//

import UIKit

class RCSCCommunityEditInfoTextCell: RCSCArrowCell {

    
    
    lazy var editTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Asset.Colors.black949494.color
        return label
    }()
    
    override class var reuseIdentifier: String {
        get {
            return String(describing: RCSCCommunityEditInfoTextCell.self)
        }
    }

    
    override func buildSubViews() {
        super.buildSubViews()
        contentView.addSubview(editTextLabel)
        editTextLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowView.snp.leading).offset(-10)
            make.width.lessThanOrEqualTo(kScreenWidth*0.5 - 44)
        }
        
    }
}
