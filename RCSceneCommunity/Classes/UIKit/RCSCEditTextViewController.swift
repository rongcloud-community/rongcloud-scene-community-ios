//
//  RCSCEditTextViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/22.
//

import UIKit
import SVProgressHUD

class RCSCEditTextViewController: UIViewController {

    private lazy var containerView: UIView = {
            let containerView = UIView()
            containerView.backgroundColor = .white
            return containerView
        }()
        
    private lazy var header: RCSCConfirmSaveView = {
        let header = RCSCConfirmSaveView(showBackButton: false)
        header.title = self.headerTitle
        header.cancelHandler = cancelHandler
        header.saveHandler = { [weak self] in
            guard let self = self,
                  let block = self.saveHandler,
                  let nickName = self.textField.text
            else {
                SVProgressHUD.showError(withStatus: "昵称不可以为空")
                return
            }
            guard let maximumTextLength = self.maximumTextLength else {
                return block(nickName)
            }
            if nickName.utf16.count > maximumTextLength {
                SVProgressHUD.showError(withStatus: "名称最多16字符，已超出限制，请修改")
                return
            }
            block(nickName)
        }
        return header
    }()
        
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = Asset.Colors.grayF6F6F6.color
        textField.textAlignment = .left
        return textField
    }()
    
    private lazy var textFieldContainer: UIView = {
        let textFieldContainer = UIView()
        textFieldContainer.layer.masksToBounds = true
        textFieldContainer.layer.cornerRadius = 4
        textFieldContainer.backgroundColor = Asset.Colors.grayF6F6F6.color
        return textFieldContainer
    }()
    
    var placeholder: String? {
        didSet {
            if let placeholder = placeholder {
                textField.placeholder = placeholder
            }
        }
    }
    
    //字符数限制
    var maximumTextLength: Int?
    
    var saveHandler: ((String) -> Void)?
    
    var cancelHandler: (() -> Void)?
    
    let headerTitle: String
    
    init(headerTitle: String) {
        self.headerTitle = headerTitle
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RCSCKeyboardObserver.registerObserver((inputView: RCSCBox(value:containerView), contentView: RCSCBox(value:view)))
        buildSubViews()
    }
    
    deinit {
        RCSCKeyboardObserver.unRegisterObserver(inputView: textFieldContainer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let _ = containerView.layer.mask else {
            return containerView.rcscCorner(corners: [.topLeft, .topRight], radii: 30)
        }
    }

    private func buildSubViews() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(235)
        }
        
        containerView.addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        
        containerView.addSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(48)
        }
        
        textFieldContainer.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
        }
    }

}
