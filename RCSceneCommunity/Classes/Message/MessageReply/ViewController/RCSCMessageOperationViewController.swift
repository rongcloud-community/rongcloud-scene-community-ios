//
//  RCSCMessageOperationViewController.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/15.
//

import UIKit

class RCSCMessageOperationViewController: UIViewController {
    
    private lazy var contentView: RCSCMessageOperationView = {
        let items: [RCSCMessageOperation] = operations
        let instance = RCSCMessageOperationView(items, operateHandler)
        return instance
    }()
    
    private let operateHandler: RCSCOperateHandler
    
    private let operations: [RCSCMessageOperation]
    
    init(operations: Array<RCSCMessageOperation>, operateHandler: @escaping RCSCOperateHandler ) {
        self.operations = operations
        self.operateHandler = operateHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.alpha(0.2)
        
        enableClickingDismiss()

        // Do any additional setup after loading the view.
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-300)
        }
    }
}

