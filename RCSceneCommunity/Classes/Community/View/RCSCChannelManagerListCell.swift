//
//  RCSCGroupManagerListCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/15.
//

import UIKit

class RCSCChannelManagerListCell: UITableViewCell {

    static let reuseIdentifier = String(describing: RCSCChannelManagerListCell.self)
    
    static weak var currentEditCell: RCSCChannelManagerListCell? = nil
    
    var name: String? {
        didSet {
            textField.text = name
        }
    }
    
    var id: String?
    
    var type: RCSCChannelManagerListStyle?
    
    var beginEdit: ((UIView) -> Void)?
    
    var endEdit: ((UIView) -> Void)?
    
    var editName: ((String,String) -> Void)?
    
    var delete: ((_ id: String) -> Void)?
    
    private lazy var menuIcon: UIImageView = {
        let icon = UIImageView(image: Asset.Images.menuIcon.image)
        return icon
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.deleteIcon.image, for: .normal)
        button.addTarget(self, action: #selector(deleteGroup), for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.editIcon.image, for: .normal)
        button.addTarget(self, action: #selector(editGroup), for: .touchUpInside)
        return button
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = "群组名称"
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: textField)
    }
    
    @objc func textFieldTextDidChange(notification: NSNotification) {
        guard let textField = notification.object as? UITextField,
              let text = textField.text,
              let block = editName,
              let id = id
        else { return }
        block(id,text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.addSubview(menuIcon)
        menuIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 18))
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.leading.equalTo(menuIcon.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalTo(deleteButton.snp.trailing)
            make.trailing.equalTo(editButton.snp.leading)
        }
    }
    
    @objc private func deleteGroup() {
        if let id = id, let block = delete {
            block(id)
        }
    }
    
    @objc private func editGroup() {
        print("edit group")
        RCSCChannelManagerListCell.currentEditCell = self
        //在becomeFirstResponder调用block，会调用注册键盘通知，注意时序
        if let block = beginEdit {
            block(self)
        }
        self.textField.becomeFirstResponder()
    }
}

extension RCSCChannelManagerListCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return RCSCChannelManagerListCell.currentEditCell === self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text.utf16.count > 16 {
            SVProgressHUD.showError(withStatus: "名称最多16字符，已超出限制，请修改")
            return
        }
        RCSCChannelManagerListCell.currentEditCell = nil
        if let block = endEdit {
            block(self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
