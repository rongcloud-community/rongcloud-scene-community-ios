//
//  RCSCChannelCreateSectionHeader.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

class RCSCChannelCreateSectionHeader: UIView {
    
    var text: String? {
        willSet {
            if let text = newValue {
                contentLabel.text = text
            }
        }
    }

    var hideButton: Bool = false {
        willSet {
            button.isHidden = newValue
        }
    }
    
    var selectGroupHandler: (() -> Void)?
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black.alpha(0.5)
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.arrowIcon.image, for: .normal)
        button.isHidden = hideButton
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(36)
        }
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.leading.equalTo(contentLabel.snp.trailing)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectGroup))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func selectGroup() {
        if let block = selectGroupHandler {
            block()
        }
    }
}
