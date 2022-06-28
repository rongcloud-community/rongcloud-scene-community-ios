//
//  RCSCConfirmSaveView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

class RCSCConfirmSaveView: UIView {
    
    
    var saveHandler: (() -> Void)?
    
    var cancelHandler: (() -> Void)?
    
    var backHandler: (() -> Void)?
    
    var hideSaveButton = false {
        willSet {
            saveButton.isHidden = newValue
        }
    }
    
    var hideCancelButton = false {
        willSet {
            cancelButton.isHidden = newValue
        }
    }
    
    var title: String = "" {
        willSet {
            titleLabel.text = newValue
        }
    }
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(Asset.Colors.grayC4C4C4.color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.isHidden = hideCancelButton
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("保存", for: .normal)
        button.setTitleColor(Asset.Colors.blue0099FF.color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.addTarget(self, action: #selector(save), for: .touchUpInside)
        button.isHidden = hideSaveButton
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.naviBackIcon.image, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    let showBackButton: Bool
    
    init(showBackButton: Bool) {
        self.showBackButton = showBackButton
        super.init(frame: .zero)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        
        if (showBackButton) {
            addSubview(backButton)
            backButton.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 44, height: 44))
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(24)
            }
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            if (self.showBackButton) {
                make.leading.equalTo(backButton.snp.trailing)
            } else {
                make.leading.equalToSuperview().offset(36)
            }
        }
        
        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-26)
        }
        
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(saveButton.snp.leading).offset(-20)
        }
        
    }
    
    @objc private func cancel() {
        if let block = cancelHandler {
            block()
        }
    }
    
    @objc private func save() {
        if let block = saveHandler {
            block()
        }
    }
    
    @objc private func back() {
        if let block = backHandler {
            block()
        }
    }
}
