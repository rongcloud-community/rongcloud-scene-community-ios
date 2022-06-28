//
//  RCSCChannelIntroViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/24.
//

import UIKit
import SVProgressHUD

enum RCSCIntroViewControllerOperateType {
    case communityRemark
    case channelRemark
    case channelName
}

extension RCSCIntroViewControllerOperateType {
    func handle(text: String, channelId: String?, completion: (() -> Void)?) {
        switch self {
        case .communityRemark:
            let param = ["remark":text]
            RCSCCommunityManager.manager.service.updateCommunity(communityId: RCSCCommunityManager.manager.currentDetail.uid, param: param)
        case .channelRemark:
            if let channelId = channelId {
                RCSCChannelService.service.updateChannelDetail(channelId: channelId, param: ["remark": text], successCompletion: completion)
            }
        case .channelName:
            if let channelId = channelId {
                RCSCChannelService.service.updateChannelDetail(channelId: channelId, param: ["name": text], successCompletion: completion)
            }
        }
    }
}

class RCSCIntroViewController: UIViewController {
    
    private lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.backgroundColor = .white
        textView.delegate = self
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 7
        textView.layer.borderColor = Asset.Colors.grayEDEDED.color.cgColor
        textView.layer.borderWidth = 1
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 10, right: 10)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = Asset.Colors.black949494.color
        textView.text = self.intro
        textView.returnKeyType = .done
        textView.isScrollEnabled = true
        
        return textView
    }()

    var needRefreshDetail: ((String) -> Void)?
    
    //字符数限制
    var limit: Int?
    
    let intro: String
    
    let type: RCSCIntroViewControllerOperateType
    
    var channelId: String?
    
    init(intro: String, title: String, type: RCSCIntroViewControllerOperateType) {
        self.intro = intro
        self.type = type
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RCSCCommunityManager.manager.registerListener(listener: self)
        let saveItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveData))
        saveItem.tintColor = Asset.Colors.blue0099FF.color
        navigationItem.rightBarButtonItem = saveItem
        view.backgroundColor = Asset.Colors.grayE5E8EF.color
        buildSubViews()
    }
    
    private func buildSubViews() {
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(27)
            make.height.equalTo(165)
        }
    }
    
    @objc private func saveData() {
        textView.resignFirstResponder()
        
        guard let text = textView.text, text.count > 0 else {
            return SVProgressHUD.showInfo(withStatus: "请核实输入")
        }
        
        if let limit = limit ,text.utf16.count > limit {
            return SVProgressHUD.showError(withStatus: "当前输入最大\(16)个字符，超出上限，请修改")
        }
        
        type.handle(text: text, channelId: channelId) { [weak self] in
            guard let self = self,
            let closure = self.needRefreshDetail
            else { return }
            self.navigationController?.popViewController(animated: true)
            closure(text)
        }
    }
}

extension RCSCIntroViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let limit = limit else { return false }
        if range.location > limit {
            SVProgressHUD.showError(withStatus: "当前输入最大\(limit)个字符，超出上限，请修改")
            textView.text = (textView.text as NSString).substring(to: limit)
            return false
        }
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension RCSCIntroViewController: RCSCCommunityDataSourceDelegate {
    func updateCommunityInfo(_ isSuccess: Bool){
        SVProgressHUD.dismiss()
        if isSuccess {
            SVProgressHUD.showSuccess(withStatus: "修改社区简介成功")
            RCSCCommunityManager.manager.currentDetail.remark = textView.text
            if let needRefreshDetail = self.needRefreshDetail {
                needRefreshDetail(textView.text!)
            }
            navigationController?.popViewController(animated: true)
        }
        
    }
}
