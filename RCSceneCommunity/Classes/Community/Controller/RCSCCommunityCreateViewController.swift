//
//  RCSCCommunityCreateViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

import UIKit
import SVProgressHUD

class RCSCCommunityCreateViewController: UIViewController {
    
    var imageUrl: String = "\(kHost)/static/community/\(arc4random_uniform(9) + 1).png"
    
    private lazy var avatarButton: UIButton = {
        let avatarButton = UIButton(type: .custom)
        avatarButton.kf.setImage(with: URL(string: imageUrl), for: .normal, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        avatarButton.layer.masksToBounds = true
        avatarButton.layer.cornerRadius = 50
        avatarButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return avatarButton
    }()
    
    private lazy var camera: UIImageView = {
        let camera = UIImageView()
        camera.image = Asset.Images.cameraIcon.image
        return camera
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.returnKeyType = .done
        textField.backgroundColor = Asset.Colors.grayF6F6F6.color
        textField.textAlignment = .center
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(
            string: defaultCommunityName,
            attributes: [.paragraphStyle: centeredParagraphStyle]
        )
        return textField
    }()
    
    private lazy var textFieldContainer: UIView = {
        let textFieldContainer = UIView()
        textFieldContainer.layer.masksToBounds = true
        textFieldContainer.layer.cornerRadius = 29
        textFieldContainer.backgroundColor = Asset.Colors.grayF6F6F6.color
        return textFieldContainer
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton(type: .custom)
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 29
        createButton.backgroundColor = Asset.Colors.black313131.color
        createButton.setTitle("????????????", for: .normal)
        createButton.addTarget(self, action: #selector(create), for: .touchUpInside)
        return createButton
    }()
    

    var defaultCommunityName: String {
        get {
            return RCSCUser.user != nil ? "\(RCSCUser.user!.userName)?????????" : ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RCSCCommunityManager.manager.registerListener(listener: self)
        view.backgroundColor = .white
        title = "????????????????????????"
        buildSubViews()
    }
    
    @objc private func endEdit() {
        view.endEditing(true)
    }
    
    private func buildSubViews() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        view.addGestureRecognizer(tap)
        
        view.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        view.addSubview(camera)
        camera.snp.makeConstraints { make in
            make.centerX.equalTo(avatarButton.snp.trailing).offset(-15)
            make.centerY.equalTo(avatarButton.snp.bottom).offset(-15)
            make.size.equalTo(CGSize(width: 26, height: 26))
        }
        
        view.addSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.height.equalTo(58)
            make.top.equalTo(camera.snp.bottom).offset(83)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        textFieldContainer.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainer.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(58)
        }
    }
    
    @objc private func create() {
        guard let user = RCSCUser.user else {
            return SVProgressHUD.showError(withStatus: "????????????????????????????????????")
        }
        guard var name = textField.text else {
            return RCSCCommunityManager.manager.createCommunity(name: defaultCommunityName, avatar: imageUrl)
        }
        guard name.utf16.count <= 16 else {
            return SVProgressHUD.showError(withStatus: "??????????????????16????????????????????????????????????????????????")
        }
        name = name.isEmpty ? defaultCommunityName : name
        RCSCCommunityManager.manager.createCommunity(name: name, avatar: imageUrl)
    }
    
    @objc private func selectImage() {
        SVProgressHUD.show()
        RCSCImagePickerController.showImagePicker(in: self, imageSelectedCompletionClosure: {[weak self] image in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }
            guard let self = self,
                  let image = image,
                  var data = image.jpegData(compressionQuality: 0.5)
            else { return }
            if data.count > 5*RCSCMb, let value = image.get5MBLimitImage() {
                data = value
            }
            RCSCUploadApi().uploadImage(data: data).success { object in
                if let path = object {
                    SVProgressHUD.dismiss()
                    self.imageUrl = path.handeAvatarFullPath()
                    self.avatarButton.kf.setImage(with: URL(string: self.imageUrl), for: .normal, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    SVProgressHUD.showError(withStatus: "??????????????????")
                }

            }
        }, videoSelectedCompletionClosure: nil, cancelClosure: {
            SVProgressHUD.dismiss()
        })
    }
}


extension RCSCCommunityCreateViewController: RCSCCommunityDataSourceDelegate {
    func createCommunitySuccess() {
        SVProgressHUD.showInfo(withStatus: "??????????????????")
        //TODO:??????????????????????????????????????????,?????????????????????
//        for v in self.navigationController!.viewControllers {
//            if v is RCSCHomeViewController {
//                let vc = v as! RCSCHomeViewController
//                vc.communityListView.createCommunitySuccess()
//            }
//        }
        self.navigationController?.popViewController(animated: true)
    }
}
