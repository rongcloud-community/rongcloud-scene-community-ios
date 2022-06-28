//
//  RCSCActionSheetViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/11.
//

import UIKit
import SVProgressHUD

enum RCSCActionSheetViewControllerActionType: Int {
    /*成员操作*/
    case editName
    case mute
    case releaseMute
    case kickOut
    /*频道通知*/
    case followCommunity
    case all
    case at
    case never
    /*标注消息操作*/
    case jump
    case remove
    
    func title() -> String {
        switch self {
        case .editName:
            return "修改在社区的昵称"
        case .mute:
            return "禁言"
        case .releaseMute:
            return "解除禁言"
        case .kickOut:
            return "踢出"
        case .followCommunity:
            return "跟随社区设置"
        case .all:
            return "所有消息都通知"
        case .at:
            return "仅被@时通知"
        case .never:
            return "从不通知"
        case .jump:
            return "跳转"
        case .remove:
            return "移除"
        }
    }
}

class RCSCActionSheetViewController: UIViewController {
    
    private  lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        return container
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var footerView: UIView = {
        let footerView = UIView()
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayF6F6F6.color
        footerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.black, for: .normal)
        footerView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return footerView
    }()
    
    var didSelect: ((_ type: RCSCActionSheetViewControllerActionType) -> Void)?
    
    private let dataSource: Array<RCSCActionSheetViewControllerActionType>
    
    init (dataSource: Array<RCSCActionSheetViewControllerActionType>) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .pageSheet
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildSubViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let _ = container.layer.mask else {
            return container.rcscCorner(corners: [.topLeft, .topRight], radii: 30)
        }
    }
    
    private func buildSubViews() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(54*dataSource.count + 120)
        }
        
        container.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        container.addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
    }
    
    @objc private func dismissController() {
        dismiss(animated: true, completion: nil)
    }
}

extension RCSCActionSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = dataSource[indexPath.row].title()
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let block = didSelect {
            dismiss(animated: true, completion: nil)
            block(dataSource[indexPath.row])
        }
    }
}
