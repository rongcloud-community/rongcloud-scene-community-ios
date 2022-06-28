//
//  RCSCProfileHeaderView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/18.
//

import UIKit

class RCSCProfileHeaderView: UIView {

    private lazy var icon: UIImageView = {
        let icon = UIImageView(image: Asset.Images.profileLogoIcon.image)
        icon.contentMode = .topRight
        return icon
    }()
    
    private lazy var avatar: UIImageView = {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFill
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 50
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.borderWidth = 3
        avatar.backgroundColor = Asset.Colors.blue0099FF.color
        return avatar
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.text = "MC🐿magic"
        return label
    }()
    
    
    private lazy var genderIcon = UIImageView(image: Asset.Images.maleIcon.image)
    
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("个人信息", for: .normal)
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        return button
    }()
    
    var editProfileHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        backgroundColor = Asset.Colors.blue0099FF.color
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 100))
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-74)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatar)
            make.top.equalTo(avatar.snp.bottom).offset(15)
        }
        
        addSubview(genderIcon)
        genderIcon.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(Asset.Images.maleIcon.image.size)
        }
        
        addSubview(profileButton)
        profileButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.trailing.equalToSuperview().offset(-20)
        }
        refresh()
    }
    
    @objc private func editProfile() {
        if let block = editProfileHandler {
            block()
        }
    }
    func refresh() {
        RCSCUser.user = RCSCUser.RCSCGetUser()
        nameLabel.text = RCSCUser.user?.userName
     
        if let imageUrlStr = RCSCUser.user?.portrait, imageUrlStr.count > 0 { //默认头像逻辑
            let imgUrlStr = (RCSCUser.user?.portrait ?? "").handeAvatarFullPath()
            avatar.setImage(with: imgUrlStr)
        }else{
            avatar.image = Asset.Images.defaultAvatarIcon.image
        }
        
        if let sexInt = RCSCUser.user?.sex {
            if sexInt == 1 {
                genderIcon.image = Asset.Images.maleIcon.image
            }else{
                genderIcon.image = Asset.Images.femaleIcon.image
            }
        }
    }
}
