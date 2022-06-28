//
//  RCSCChannelCreateChannelCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/14.
//

class RCSCChannelCreateCategoryCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: RCSCChannelCreateCategoryCell.self)
    
    var data: (selected: Bool, locked: Bool, title: String, subTitle: String, selectedImage: UIImage, normalImage: UIImage)? {
        willSet {
            if let data = newValue {
                titleLabel.text = data.title
                subTitleLabel.text = data.subTitle
                icon.image = data.selected ? data.selectedImage : data.normalImage
                titleLabel.textColor = data.selected ? Asset.Colors.blue0099FF.color : Asset.Colors.grayC1C1C1.color
                subTitleLabel.textColor = data.selected ? Asset.Colors.blue0099FF.color : Asset.Colors.grayC1C1C1.color
                container.backgroundColor = data.selected ? Asset.Colors.blueE1F3FF.color : Asset.Colors.grayF1F1F1.color
                container.layer.borderColor = data.selected ? Asset.Colors.blueA0D9FF.color.cgColor : Asset.Colors.grayF1F1F1.color.cgColor
                lockIcon.isHidden = !data.locked
            }
        }
    }
    
    private lazy var container: UIView = {
        let container = UIView()
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 11
        container.layer.borderWidth = 2
        return container
    }()
    
    private lazy var icon: UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    private lazy var lockIcon: UIImageView = {
        let icon = UIImageView(image: Asset.Images.lockIcon.image)
        return icon
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 22))
        }
        
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(10)
            make.bottom.equalTo(container.snp.centerY)
        }
        
        container.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(10)
            make.top.equalTo(container.snp.centerY).offset(4)
        }
        
        container.addSubview(lockIcon)
        lockIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-17)
            make.centerY.equalTo(icon)
            make.size.equalTo(CGSize(width: 13, height: 17))
        }
    }
}
