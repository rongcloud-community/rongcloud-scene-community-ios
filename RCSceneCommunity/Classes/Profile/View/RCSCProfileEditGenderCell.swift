//
//  RCSCProfileEditGenderCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/21.
//

import UIKit
import SVProgressHUD

class RCSCProfileEditGenderCell: RCSCProfileEditBaseCell {

    static let reuseIdentifier = String(describing: RCSCProfileEditGenderCell.self)
    var getSexStrclouse: ((String) -> Void)?
    lazy var maleButton: UIButton = {
        let button = genderButton(title: "男",
                                  normalImage: Asset.Images.profileMaleNormalIcon.image,
                                  selectedImage: Asset.Images.profileMaleSelectedIcon.image,
                                  normalBgImageColor: Asset.Colors.grayF3F4F5.color,
                                  selectedBgImageColor: Asset.Colors.blue72BEF8.color,
                                  normalTextColor: Asset.Colors.black020037.color,
                                  selectedTextColor: .white,
                                  selector: #selector(maleClick(sender:)))
        return button
    }()
    
   lazy var femaleButton: UIButton = {
        let button = genderButton(title: "女",
                                  normalImage: Asset.Images.profileFemaleNormalIcon.image,
                                  selectedImage: Asset.Images.profileFemaleSelectedIcon.image,
                                  normalBgImageColor: Asset.Colors.grayF3F4F5.color,
                                  selectedBgImageColor: Asset.Colors.redED8CAA.color,
                                  normalTextColor: Asset.Colors.black020037.color,
                                  selectedTextColor: .white,
                                  selector: #selector(femaleClick(sender:)))
        return button
    }()
    
    private func genderButton (
        title: String,
        normalImage: UIImage,
        selectedImage: UIImage,
        normalBgImageColor: UIColor,
        selectedBgImageColor: UIColor,
        normalTextColor: UIColor,
        selectedTextColor: UIColor,
        selector: Selector
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.contentMode = .scaleAspectFill
        button.setTitle(title, for: .normal)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.setTitleColor(normalTextColor, for: .normal)
        button.setTitleColor(selectedTextColor, for: .selected)
        button.setBackgroundImage(UIImage.createImageWithColor(color: normalBgImageColor), for: .normal)
        button.setBackgroundImage(UIImage.createImageWithColor(color: selectedBgImageColor), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildSubViews()
        maleButton.isSelected = true
        femaleButton.isSelected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        
        contentView.addSubview(femaleButton)
        femaleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 82, height: 33))
        }
        
        contentView.addSubview(maleButton)
        maleButton.snp.makeConstraints { make in
            make.trailing.equalTo(femaleButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 82, height: 33))
        }
    }
    
    @objc private func maleClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        femaleButton.isSelected = !sender.isSelected
//        SVProgressHUD.showInfo(withStatus: "男")
//        RCSCUser.user?.sex = 1
        if let getSexStrclouse = getSexStrclouse {
            getSexStrclouse("1")
        }
    }
    
    @objc private func femaleClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        maleButton.isSelected = !sender.isSelected
//        SVProgressHUD.showInfo(withStatus: "女")
//        RCSCUser.user?.sex = 2
        if let getSexStrclouse = getSexStrclouse {
            getSexStrclouse("2")
        }
    }
}
