//
//  RCSCProfileEditNameCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/21.
//

import UIKit

class RCSCProfileEditNameCell: RCSCProfileEditBaseCell {
    var getNameStrclouse: ((String) -> Void)?
    static let reuseIdentifier = String(describing: RCSCProfileEditNameCell.self)
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.editIcon.image, for: .normal)
        button.addTarget(self, action: #selector(editName), for: .touchUpInside)
        return button
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
//        textField.text = "昵称"
        textField.delegate = self
        textField.textColor = Asset.Colors.black949494.color
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.returnKeyType = .done
        return textField
    }()
    
    var editEnable = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
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
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(editButton.snp.leading)
        }
    }
    
    @objc private func editName() {
        editEnable = true
        textField.becomeFirstResponder()
    }
}

extension RCSCProfileEditNameCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editEnable
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editEnable = false
        guard let text = textField.text , text.count > 0 else {
            return
        }
        if let getNameStrclouse = getNameStrclouse {
            getNameStrclouse(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editEnable = false
        textField.resignFirstResponder()
        return true
    }
}
