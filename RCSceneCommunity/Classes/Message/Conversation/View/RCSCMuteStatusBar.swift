//
//  RCSCMuteStatusBar.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/6/24.
//

import UIKit

class RCSCMuteStatusBar: UIView {

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black.alpha(0.2)
        label.text = "您被禁止在该社区发言"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(18)
        }
        
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayE5E8EF.color
        
        addSubview(line)
        line.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
