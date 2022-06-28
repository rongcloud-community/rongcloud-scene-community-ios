//
//  RCSCPrivateMessageCell.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/4/27.
//

import UIKit

class RCSCPrivateMessageCell:UITableViewCell {
    
    static let reuseIdentifier = String(describing: RCSCPrivateMessageCell.self)
    

    //MARK: -  lazy property


    lazy var avatarImgView: UIImageView = {
        let imgV = UIImageView()
        imgV.layer.masksToBounds = true
        imgV.layer.cornerRadius = 27
        return imgV
    }()
    
    lazy var dotBandView: UIView = {
        let v = UIView()
        v.bounds = CGRect.init(x: 0, y: 0, width: 10, height: 10)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = v.bounds.size.height * 0.5
        v.backgroundColor = Asset.Colors.pinkF31D8A.color
        return v
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = textColor
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = timeTextColor
        label.textAlignment = .right
        return label
    }()
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = descTextColor
        label.numberOfLines = 1
        return label
    }()
    

    
    // MARK: - Computed Property
    
    var textColor: UIColor = Asset.Colors.black282828.color {
        willSet {
            titleLabel.textColor = newValue
        }
    }
    var timeTextColor: UIColor = Asset.Colors.black282828.color.alpha(0.2) {
        willSet {
            timeLabel.textColor = newValue
        }
    }
    
    var descTextColor: UIColor = Asset.Colors.black282828.color.alpha(0.54) {
        willSet {
            descLabel.textColor = newValue
        }
    }
    
    var isHiddenDotBander = true {
        willSet {
            dotBandView.isHidden = newValue
        }
    }
    
    
    var avatarURLStr: String? {
        willSet {
            guard let url = newValue else { return }
            avatarImgView.setImage(with: url)
        }
    }
    


    
    
    var cellData: (cellId: String,title: String, subTitle: String, timeTitle: String,avatarStr: String,isHiddenDot: Bool)?  { //FIXME: 模拟测试
        willSet{
            if let data = newValue {
//                print(data)
                titleLabel.text = data.title
                timeLabel.text = data.timeTitle
                descLabel.text = data.subTitle
                avatarURLStr = data.avatarStr
                isHiddenDotBander = data.isHiddenDot
            }
        }
    }
    
    

    //MARK: - pubilc Methodist
 
    public func setCellModel(_ any:RCMessage?) {
        //TODO: 可根据数据模型进行数据映射
        //模拟数据
        cellData = ("cellId","Savannah Nguyen"," @所有人 帮我处理一下这个问题啊 大家快帮我看看这关 怎么过？！你确定上次见到的是我吗？","03: 53 PM","https://tva1.sinaimg.cn/large/e6c9d24ely1h1obya3sqmj20im0imgnn.jpg",false)
    }
    
  
    


    //MARK: - private Methodist


    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.addSubview(avatarImgView)
        avatarImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(18)
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
    
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(14)
            make.top.equalTo(avatarImgView)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-35).priority(.high)
            make.leading.equalTo(titleLabel.snp.trailing).offset(20).priority(.low)
        }
        
        
        
        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-35)
            make.bottom.equalToSuperview().offset(-22)
        }

        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal) //宽度不够时，可以被压缩
        titleLabel.setContentHuggingPriority(.required, for: .horizontal) //抱紧，类似于sizefit，不会根据父view长度变化
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal) //不可以被压缩，尽量显示完整
        
        contentView.addSubview(dotBandView)
        dotBandView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 10, height: 10))
            make.top.equalTo(avatarImgView).offset(3.5)
            make.trailing.equalTo(avatarImgView).offset(-4.5)
        }
    }
    
}
