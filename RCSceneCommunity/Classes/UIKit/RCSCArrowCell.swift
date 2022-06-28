//
//  RCSCArrowCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/23.
//

import UIKit

class RCSCArrowCell: UITableViewCell {

    class var reuseIdentifier: String {
        get {
            return String(describing: RCSCArrowCell.self)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = Asset.Colors.black363636.color
        label.numberOfLines = 3
        return label
    }()
    
    lazy var arrowView: UIImageView = {
        let arrow = UIImageView(image: Asset.Images.arrowIcon.image)
        return arrow
    }()
    
    var text: String = "" {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildSubViews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildSubViews() {
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            
        }
        
        contentView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(Asset.Images.arrowIcon.image.size)
        }
    }
}
