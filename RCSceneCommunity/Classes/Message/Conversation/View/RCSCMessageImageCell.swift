//
//  RCSCMessageImageCell.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/21.
//

import UIKit


class RCSCMessageImageCell: RCSCMessageBaseCell {
    
    lazy var contentImageView: UIImageView = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildSubviews()
        type = .image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubviews() {
        contentView.addSubview(contentImageView)
        contentImageView.snp.makeConstraints { make in
            make.width.equalTo(138)
            make.height.equalTo(106)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(10)
        }
        
        contentView.addSubview(sendFailView)
        sendFailView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(contentImageView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 195, height: 25))
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let message = message,
              let type = type,
              let block = contentTapHandler
        else { return }
        block(message,type,contentImageView)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
       
        let width = layoutAttributes.frame.width
        layoutAttributes.frame.size = CGSize(width: width, height: 190)
        return layoutAttributes
    }
    
    override func updateUI(_ message: RCMessage) -> RCSCCellProtocol {
        super.updateUI(message)
        guard
            let content = message.content as? RCImageMessage
        else { return self }

        contentImageView.image = nil
        
        if let path = content.realLocalPath(),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let image = UIImage(data: data) {
            contentImageView.image = image
        } else if let thum = content.thumbnailImage {
            contentImageView.image = thum
        } else if let url = content.remoteUrl {
            contentImageView.setImage(with: url)
        }
        
        return self
    }
}

extension RCMediaMessageContent {
    #warning("localpath有bug, 后续需要升级接口，已经反馈给IM团队")
    //TODO: 后续需要升级
    func realLocalPath() -> String? {
        return getPath(separator: "/RongCloud/")
    }
    
    func realCommunityPath() -> String? {
        return getPath(separator: "/rcsccommunity/")
    }
    
    private func getPath(separator: String) -> String? {
        if let value = localPath, value.contains(separator) {
            let result = value.components(separatedBy: separator)
            if (result.count == 2) {
                let home = NSHomeDirectory()
                let rc = home + "/Library/Caches\(separator)"
                let dst = rc + result.last!
                return dst
            }
        }
        return nil
    }
}
