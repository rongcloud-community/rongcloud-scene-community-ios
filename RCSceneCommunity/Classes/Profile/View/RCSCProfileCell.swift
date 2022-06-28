//
//  RCSCProfileCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/21.
//

import UIKit

enum RCSCProfileCellStyle {
    case normal
    case arrow
}

class RCSCProfileCell: UITableViewCell {

    static let reuseIdentifier = String(describing: RCSCProfileCell.self)
    
    lazy var arrowIcon: UIImageView = {
        let icon = UIImageView(image: Asset.Images.arrowIcon.image)
        return icon
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = textColor
        return label
    }()
    
    var cellStyle: RCSCProfileCellStyle = .normal {
        willSet {
            arrowIcon.isHidden = newValue == .normal
        }
    }
    
    var textColor: UIColor = Asset.Colors.black949494.color {
        willSet {
            titleLabel.textColor = newValue
        }
    }
    
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        
        contentView.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(Asset.Images.arrowIcon.image.size)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(31)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowIcon.snp.leading).offset(10)
        }
    }
    
}
