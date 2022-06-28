//
//  RCSCConversationAdditionView.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/18.
//

import UIKit

extension RCSCMessageType {
    var image: UIImage? {
        switch self {
        case .image: return Asset.Images.additionImage.image
        case .video: return Asset.Images.additionVideo.image
        default: return nil
        }
    }
    
    var title: String? {
        switch self {
        case .image: return "图片"
        case .video: return "视频"
        default: return nil
        }
    }
}

class RCSCConversationAdditionView: UIView {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 25
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 85)
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.register(RCSCConversationAdditionCell.self, forCellWithReuseIdentifier: "Cell")
        view.contentInset = UIEdgeInsets(top: 13, left: 18, bottom: 13, right: 18)
        return view
    }()
    
    private lazy var items: [RCSCMessageType] = [.image, .video]
    
    weak var delegate: RCSCTmpInputViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(120)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RCSCConversationAdditionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return (cell as! RCSCConversationAdditionCell).updateUI(items[indexPath.item])
    }
}

extension RCSCConversationAdditionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.inputViewDidSelectedMediaType(item)
    }
}

class RCSCConversationAdditionCell: UICollectionViewCell {
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(white: 245 / 255.0, alpha: 1)
        contentView.layer.borderColor = UIColor(white: 230 / 255.0, alpha: 1).cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 5.5
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.75)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(_ item: RCSCMessageType) -> UICollectionViewCell {
        titleLabel.text = item.title
        imageView.image = item.image
        return self
    }
}
