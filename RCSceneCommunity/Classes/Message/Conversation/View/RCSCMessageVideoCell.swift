//
//  RCSCMessageVideoCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/24.
//

import UIKit

class RCSCMessageVideoCell: RCSCMessageBaseCell {
    
    var cellHeight = 190.0
    
    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    
    lazy var playImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Images.messagePlay.image
        return imageView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = Asset.Colors.black838383.color.alpha(0.2)
        progressView.progressTintColor = Asset.Colors.blue0099FF.color
        progressView.progress = 0
        progressView.isHidden = true
        for view in progressView.subviews {
            if let imageView = view as? UIImageView {
                imageView.layer.masksToBounds = true
                imageView.layer.cornerRadius = 2.5
            }
        }
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubviews()
        type = .video
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(138)
            make.height.equalTo(106)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(10)
        }
        
        thumbnailImageView.addSubview(playImageView)
        playImageView.snp.makeConstraints { make in
            make.size.equalTo(Asset.Images.messagePlay.image.size)
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(7)
            make.leading.equalTo(thumbnailImageView.snp.leading)
            make.trailing.equalTo(thumbnailImageView.snp.trailing)
            make.height.equalTo(5)
        }
        
        contentView.addSubview(sendFailView)
        sendFailView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 195, height: 25))
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let message = message,
              let type = type,
              let block = contentTapHandler
        else { return }
        block(message,type,thumbnailImageView)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
       
        let width = layoutAttributes.frame.width
        layoutAttributes.frame.size = CGSize(width: width, height: cellHeight)
        return layoutAttributes
    }
    
    override func updateUI(_ message: RCMessage) -> RCSCCellProtocol {
        super.updateUI(message)
        guard
            let content = message.content as? RCSightMessage
        else { return self }
        
        progressView.isHidden = true
        
        thumbnailImageView.image = content.thumbnailImage
        
        return self
    }
    
    override func updateProgress(messageId: Int, progress: Float) {
        progressView.isHidden = false
        progressView.progress = progress/100
    }
    
    override func sendMessageFinished(messageId: Int, code: Int) {
        progressView.isHidden = true
        sendFailView.isHidden = code == RCErrorCode.RC_SUCCESS.rawValue
    }
}
