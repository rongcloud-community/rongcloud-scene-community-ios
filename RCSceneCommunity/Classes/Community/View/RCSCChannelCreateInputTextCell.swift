//
//  RCSCChannelCreateGroupCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

class RCSCChannelCreateInputTextCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: RCSCChannelCreateInputTextCell.self)
    
    var inputTextHandler: ((String?) -> Void)?
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = Asset.Colors.grayF6F6F6.color
        textField.textAlignment = .left
        textField.placeholder = "给你频道起个名字吧"
        return textField
    }()
    
    private lazy var icon: UIImageView = {
        let icon = UIImageView(image: Asset.Images.bigGrayHashtagIcon.image)
        return icon
    }()
    
    private lazy var textFieldContainer: UIView = {
        let textFieldContainer = UIView()
        textFieldContainer.layer.masksToBounds = true
        textFieldContainer.layer.cornerRadius = 22
        textFieldContainer.backgroundColor = Asset.Colors.grayF6F6F6.color
        return textFieldContainer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        textFieldContainer.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 15, height: 13))
        }
        
        textFieldContainer.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: textField)
    }
    
    @objc func textFieldTextDidChange(notification: NSNotification) {
        guard let textField = notification.object as? UITextField,
              let inputTextHandler = self.inputTextHandler,
              let text = textField.text
        else { return }
        inputTextHandler(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

