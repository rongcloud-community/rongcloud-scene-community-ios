//
//  RCSCProfileEditAvatarCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/21.
//

import UIKit
import SVProgressHUD

class RCSCProfileEditAvatarCell: RCSCProfileEditBaseCell {
    var getImgUrlStrclouse: ((String) -> Void)?
    static let reuseIdentifier = String(describing: RCSCProfileEditAvatarCell.self)
    var imageUrlStr: String? {
        willSet{
            guard let imageUrlStr = newValue else {
                return
            }
            avatar.setImage(with: imageUrlStr, placeholder: Asset.Images.defaultAvatarIcon.image)
        }
    }
        
    private lazy var avatar: UIImageView = {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFill
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 50
        avatar.backgroundColor = Asset.Colors.blue0099FF.color
        return avatar
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("更换", for: .normal)
        button.setImage(Asset.Images.arrowIcon.image, for: .normal)
        button.setTitleColor(Asset.Colors.black949494.color, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 46, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.addTarget(self, action: #selector(editAvatar), for: .touchUpInside)
        return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 54, height: 44))
        }
        
        contentView.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.trailing.equalTo(button.snp.leading).offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
    }
    
    @objc private func editAvatar() {
//        SVProgressHUD.showInfo(withStatus: "更改头像")
        updatePhotoInfo()
    }
    
    func  updatePhotoInfo(){
        
        guard let controller = self.controller else { return }
        
        SVProgressHUD.show(withStatus: "唤起相册功能请中...")
        
        RCSCImagePickerController.showImagePicker(in: controller, imageSelectedCompletionClosure: {[weak self] image in
            SVProgressHUD.dismiss()
            defer {
                self?.controller!.dismiss(animated: true, completion: nil)
            }
            guard let self = self,
                  let image = image,
                  let data =  image.scaleToFitAtCenter(size: CGSize.init(width: 100, height: 100))?.jpegData(compressionQuality: 0.5) //image.jpegData(compressionQuality: 0.5)
            else { return }
            RCSCUploadApi().uploadImage(data: data).success { object in
                if let path = object {
                    if let action = self.getImgUrlStrclouse {
                       let urlStr =  path //"\(kHost)/file/show?path=\(path)"
                        action(urlStr)
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "图片上传失败")
                }

            }
        }, videoSelectedCompletionClosure: nil) {
            SVProgressHUD.dismiss()
        }
    }
}
