//
//  RCSCUnreadBar.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/25.
//

import UIKit

class RCSCUnreadBar: UIView {

    lazy var iconImageView: UIImageView = {
        let icon = UIImageView(image: Asset.Images.messageJumpToUnread.image)
        return icon
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    var unreadCount: Int32 = 0 {
        didSet {
            isHidden = unreadCount == 0
            contentLabel.text = "\(unreadCount)条未读消息"
        }
    }
    
    var tapCompletion: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Asset.Colors.blue0099FF.color
        isHidden = true
        buildSubviews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let _ = layer.mask else {
            return self.rcscCorner(corners: [.topLeft, .bottomLeft], radii: 18)
        }
    }
    
    private func buildSubviews() {
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func tap() {
        if let tapCompletion = tapCompletion {
            tapCompletion()
        }
    }
}
