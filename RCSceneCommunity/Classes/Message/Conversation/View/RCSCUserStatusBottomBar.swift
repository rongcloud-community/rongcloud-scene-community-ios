//
//  RCSCUserStatusBottomBar.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/17.
//

import UIKit

extension RCSCCommunityUserStatus {
    func text() -> String {
        switch self {
        case .join:
            return "加入社区后即可参与互动"
        case .check:
            return "加入社区后即可参与互动"
        case .reject:
            return "您的申请被拒绝，可重新申请加入"
        case .joined:
            return "加入社区后即可参与互动"
        default:
            return "加入社区后即可参与互动"
        }
    }
    
    func buttonTitle() -> String {
        switch self {
        case .join:
            return "加入"
        case .check:
            return "审核中"
        case .reject:
            return "加入"
        case .joined:
            return ""
        default:
            return ""
        }
    }
}

class RCSCUserStatusBottomBar: UIView {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = status.text()
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.setTitle(status.buttonTitle(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        switch status {
        case .check:
            button.backgroundColor = .white
            button.setTitleColor(Asset.Colors.blue0099FF.color, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = Asset.Colors.blue0099FF.color.cgColor
        default:
            button.backgroundColor = Asset.Colors.blue0099FF.color
            button.layer.borderWidth = 0
            button.setTitleColor(.white, for: .normal)
            break
        }
        return button
    }()
    
    var status: RCSCCommunityUserStatus
    
    var join: (() -> Void)?
    
    init(status: RCSCCommunityUserStatus) {
        self.status = status
        super.init(frame: .zero)
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 78, height: 34))
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(button)
            make.leading.equalToSuperview().offset(36)
            make.trailing.equalTo(button).offset(-36)
        }
        
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayE5E8EF.color
        addSubview(line)
        line.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    @objc private func buttonClick() {
        if let join = join, status == .join || status == .reject {
            join()
        }
    }
    
    func changeToCheckStatus() {
        status = .check
        button.backgroundColor = .white
        button.setTitleColor(Asset.Colors.blue0099FF.color, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = Asset.Colors.blue0099FF.color.cgColor
        button.setTitle(status.buttonTitle(), for: .normal)
        label.text = status.text()
    }
    
    func changeToRejectStatus() {
        status = .reject
        button.backgroundColor = Asset.Colors.blue0099FF.color
        button.layer.borderWidth = 0
        button.setTitleColor(.white, for: .normal)
        button.setTitle(status.buttonTitle(), for: .normal)
        label.text = status.text()
    }
}
