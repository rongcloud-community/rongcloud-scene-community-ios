//
//  RCSCCommunityEditNameViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/28.
//

import UIKit
import SVProgressHUD

class RCSCCommunityEditNameViewController: UIViewController {
    
    var needRefreshDetail: ((String) -> Void)?
    
    public var communityDetail: RCSCCommunityDetailData?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = Asset.Colors.black949494.color
        label.text = "群名称"
        return label
    }()
    
    private lazy var textField: UITextField = {
            let textField = UITextField()
        textField.backgroundColor = .white
            textField.textAlignment = .left
        textField.placeholder = communityDetail?.name ?? ""
        return textField
    }()
    
    private lazy var textFieldContainer: UIView = {
        let textFieldContainer = UIView()
        textFieldContainer.layer.masksToBounds = true
        textFieldContainer.layer.cornerRadius = 4
        textFieldContainer.backgroundColor = .white
        return textFieldContainer
    }()
    
    var communityId: String? {
        get {
            return communityDetail?.uid
        }
    }
    
    init(communityDetail: RCSCCommunityDetailData?){
        super.init(nibName: nil, bundle: nil)
        self.communityDetail = communityDetail
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RCSCCommunityManager.manager.registerListener(listener: self)
        title = "修改社区名称"
        let saveItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveData))
        saveItem.tintColor = Asset.Colors.blue0099FF.color
        navigationItem.rightBarButtonItem = saveItem
        view.backgroundColor = Asset.Colors.grayF4F6FA.color
        buildSubViews()
    }
    
    private func buildSubViews() {
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(36)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(26)
            make.trailing.equalToSuperview().offset(-36)
        }
        
        view.addSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
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
    
    @objc private func saveData() {
        guard let name = textField.text, name.count > 0  else {
            SVProgressHUD.showInfo(withStatus: "请核实输入")
            return
        }
        guard let communityId = self.communityId else {
            SVProgressHUD.show(withStatus: "communityId 为空,请核实")
            return
        }
        if name.utf16.count > 16 {
            SVProgressHUD.showError(withStatus: "名称最多16字符，已超出限制，请修改")
            return
        }
        let params = ["name": name]
        SVProgressHUD.show()
        RCSCCommunityManager.manager.updateCommunity(communityId: communityId, param: params)
    }
}


extension RCSCCommunityEditNameViewController: RCSCCommunityDataSourceDelegate {
    func updateCommunityInfo(_ isSuccess: Bool){
        SVProgressHUD.dismiss()
        if isSuccess {
            SVProgressHUD.showSuccess(withStatus: "社区名称成功")
            RCSCCommunityManager.manager.currentDetail.name = textField.text!
            if let needRefreshDetail = self.needRefreshDetail {
                needRefreshDetail(textField.text!)
            }
            navigationController?.popViewController(animated: true)
        }
        
    }
}
