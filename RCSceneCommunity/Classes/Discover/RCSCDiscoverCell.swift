//
//  RCSCDiscoverCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/22.
//

import UIKit

class RCSCDiscoverCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: RCSCDiscoverCell.self)
    
    var data: RCSCDiscoverListRecord? {
        willSet {
            if let value = newValue {
                titleLabel.text = value.name
                descLabel.text = value.remark
                avatarView.setImage(with: value.portrait)
                personCountLabel.text = "\(value.personCount)人"
                if !value.coverUrl.isEmpty {
                    imageView.setImage(with: value.coverUrl)
                } else {
                    imageView.setImage(with: value.portrait)
                }
            }
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Asset.Colors.blue72BEF8.color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Asset.Colors.blue0099FF.color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var descTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.black313131.color
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "简介："
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Asset.Colors.black313131.color
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    private lazy var personCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.backgroundColor = Asset.Colors.whiteFAFAFA.color
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(96)
        }
        
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(13)
            make.centerY.equalTo(imageView.snp.bottom).offset(-10)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(22)
        }
        
        contentView.addSubview(descTitleLabel)
        descTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.height.equalTo(16)
        }
        
        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(descTitleLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(personCountLabel)
        personCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(imageView.snp.bottom).offset(-4)
        }
    }
}
