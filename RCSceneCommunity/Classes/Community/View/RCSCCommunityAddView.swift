//
//  RCSCCommunityAddView.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/8.
//

import UIKit

class RCSCCommunityAddView: UICollectionReusableView {

    var createCommunityHandler: (() -> Void)?
    
    static let reuseIdentifier = String(describing: RCSCCommunityAddView.self)
    
    lazy var contentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.Images.communityAdd.image, for: .normal)
        button.addTarget(self, action: #selector(createCommunity), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        addSubview(contentButton)
        contentButton.snp.makeConstraints { make in
            make.top.equalTo(self).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func createCommunity() {
        if let block = createCommunityHandler {
            block()
        }
    }
}


class RCSCCommunityEmptyFooterView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: RCSCCommunityEmptyFooterView.self)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
