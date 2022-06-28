//
//  RCSCMessageQuoteView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/28.
//

import UIKit

extension RCSCMessageOperation {
    var icon: UIImage {
        switch self {
        case .quote:
            return Asset.Images.messageQuoteIcon.image
        default:
            return Asset.Images.messageEditIcon.image
        }
    }
}

class RCSCMessageOperationInputBar: UIView {

    static let height = 38
    
    var dismiss: (() -> Void)?
    
    var text = "" {
        didSet {
            contentLabel.text = text
        }
    }
    
    var operateType: RCSCMessageOperation {
        willSet {
            typeIconImageView.image = newValue.icon
        }
    }
    
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = Asset.Colors.grayF3F3F3.color
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 14
        return view
    }()
    
    private lazy var typeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = operateType.icon
        return imageView
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.messageDeleteIcon.image, for: .normal)
        button.addTarget(self, action: #selector(_dismiss), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Asset.Colors.black282828.color.alpha(0.5)
        return label
    }()
    override init(frame: CGRect) {
        self.operateType = .edit
        super.init(frame: frame)
        backgroundColor = .white
        layer.masksToBounds = true
        buildSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(6)
            make.height.equalTo(28)
        }
        
        container.addSubview(typeIconImageView)
        typeIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(operateType.icon.size)
        }
        
        container.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 34, height: 34))
        }
        
        container.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(typeIconImageView.snp.trailing).offset(8)
            make.trailing.equalTo(dismissButton.snp.leading).offset(-8)
            make.top.bottom.equalToSuperview()
        }
    }
    
    @objc private func _dismiss() {
        isHidden = true
        if let dismiss = dismiss {
            dismiss()
        }
    }
}
