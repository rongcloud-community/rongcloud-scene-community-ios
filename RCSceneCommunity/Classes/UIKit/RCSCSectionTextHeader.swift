//
//  RCSCSectionTextHeader.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/24.
//

import UIKit

class RCSCSectionTextHeader: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = Asset.Colors.black949494.color
        label.text = text
        return label
    }()
    
    let align: RCSCTextAlignment
    
    let text: String
    
    init(text: String, align: RCSCTextAlignment = .bottom) {
        self.text = text
        self.align = align
        super.init(frame: .zero)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        backgroundColor = .clear
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            switch self.align {
            case .top:
                make.top.equalToSuperview().offset(6)
            case .center:
                make.centerY.equalToSuperview()
            default:
                make.bottom.equalToSuperview().offset(-6)
            }
        }
    }
}
