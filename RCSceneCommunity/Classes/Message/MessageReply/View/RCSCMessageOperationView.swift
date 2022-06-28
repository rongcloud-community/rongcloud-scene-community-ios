//
//  RCSCMessageReplyItemView.swift
//  Kingfisher
//
//  Created by shaoshuai on 2022/3/15.
//

import UIKit

enum RCSCMessageOperation: Equatable {
    case reply
    case edit
    case quote
    case copy
    case delete
    case mark
    case deleMark
    case custom(image: UIImage?, title: String?)
    
    var image: UIImage? {
        switch self {
        case .reply: return Asset.Images.messageEdit.image
        case .edit: return Asset.Images.messageEdit.image
        case .quote: return Asset.Images.messageQuote.image
        case .copy: return Asset.Images.messageCopy.image
        case .delete: return Asset.Images.messageRecall.image
        case .mark: return Asset.Images.messageMark.image
        case .deleMark: return Asset.Images.messageMark.image
        case let .custom(image, _): return image
        }
    }
    
    var title: String? {
        switch self {
        case .reply: return "回复"
        case .edit: return "编辑"
        case .quote: return "引用"
        case .copy: return "复制"
        case .delete: return "撤回"
        case .mark: return "标注"
        case .deleMark: return "取消标注"
        case let .custom(_, title): return title
        }
    }
}

typealias RCSCOperateHandler = ((RCSCMessageOperation) -> Void)

class RCSCMessageOperationView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.backgroundColor = .white
        instance.register(RCSCMessageOperationItemCell.self, forCellWithReuseIdentifier: "Cell")
        instance.contentInset = UIEdgeInsets(top: 45, left: 15, bottom: 15, right: 15)
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    
    private lazy var actionLineView = UIView()
    private lazy var actionAreaView = UIView()
    
    let operations: [RCSCMessageOperation]

    private let operateHandler: RCSCOperateHandler
    
    init(_ operations: [RCSCMessageOperation], _ operateHandler: @escaping RCSCOperateHandler, frame: CGRect = .zero) {
        self.operateHandler = operateHandler
        self.operations = operations
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        actionLineView.backgroundColor = .black.alpha(0.1)
        actionLineView.layer.cornerRadius = 2.5
        addSubview(actionLineView)
        actionLineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(64)
            make.height.equalTo(5)
        }
        
        addSubview(actionAreaView)
        actionAreaView.snp.makeConstraints { make in
            make.centerX.equalTo(actionLineView)
            make.width.equalTo(84)
            make.height.equalTo(25)
        }
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        gesture.direction = .down
        addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 30, height: 30))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.mask = shapeLayer
        layer.masksToBounds = true
    }
    
    @objc private func swipeHandler(_ gesture: UISwipeGestureRecognizer) {
        controller?.dismiss(animated: true)
    }
}

extension RCSCMessageOperationView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return operations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return (cell as! RCSCMessageOperationItemCell).update(operations[indexPath.row])
            
    }
}

extension RCSCMessageOperationView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let opt = operations[indexPath.row]
        operateHandler(opt)
    }
}

extension RCSCMessageOperationView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 51) / 4
        return CGSize(width: Int(width), height: Int(width / 80 * 85))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}
