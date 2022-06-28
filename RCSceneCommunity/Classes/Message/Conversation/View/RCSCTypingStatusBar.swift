//
//  RCSCTypingStatusBar.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/30.
//

import UIKit

class RCSCTypingStatusBar: UIView {
    
    var timer: Timer?
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.gray7A808E.color
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        backgroundColor = Asset.Colors.grayE5E8EF.color
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in view: UIView, text: String) {
        isHidden = false
        contentLabel.text = text
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) {[weak self] timer in
            guard let self = self else { return }
            self.isHidden = true
        }
    }
}
