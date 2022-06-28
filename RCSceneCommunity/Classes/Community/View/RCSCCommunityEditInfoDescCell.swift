//
//  RCSCCommunityEditInfoDescCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/25.
//

import UIKit

class RCSCCommunityEditInfoDescCell: RCSCArrowCell {

    lazy var editTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Asset.Colors.black949494.color
        return label
    }()
    
    lazy var editDescLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Asset.Colors.black949494.color
        return label
    }()
    
    override class var reuseIdentifier: String {
        get {
            return String(describing: RCSCCommunityEditInfoDescCell.self)
        }
    }

    override func buildSubViews() {
        super.buildSubViews()
        
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(13)
        }
        
        arrowView.snp.remakeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(Asset.Images.arrowIcon.image.size)
        }
        
        contentView.addSubview(editTextLabel)
        editTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(arrowView)
            make.trailing.equalTo(arrowView.snp.leading).offset(-10)
        }
        
        contentView.addSubview(editDescLabel)
        editDescLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-13)
        }
        
        titleLabel.text = "xxxxx"
        editTextLabel.text = "xxxxx"
        editDescLabel.text = "xxxxx"
    }
}
