//
//  RCSCProfileEditBaseCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/21.
//

import UIKit

class RCSCProfileEditBaseCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = Asset.Colors.black949494.color
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildSubViews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        var line = UIView()
        line.backgroundColor = Asset.Colors.grayEDEDED.color
        
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        line = UIView()
        line.backgroundColor = Asset.Colors.grayEDEDED.color
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.text =  "昵称"
    }
}
