//
//  RCSCCommunityManagerViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/10.
//

import UIKit
import SVProgressHUD

enum RCSCCommunityManagerPopActionType: Int {
    case usersList
    case nickName
    case createGroup
    case createChannel
    case notify
    case manager
    case quit
}

private extension RCSCCommunityManagerPopActionType {
    
    var title: String {
        get {
            switch self {
            case .usersList:
                return "社区成员"
            case .nickName:
                return "我在本社区的昵称"
            case .createGroup:
                return "创建分组"
            case .createChannel:
                return "创建频道"
            default:
                return ""
            }
        }
    }
}

class RCSCCommunityManagerPopViewController: UIViewController {

    var dismissCompletion:((_ cellType: RCSCCommunityManagerPopActionType) -> Void)?
    
    var avatarUrl: String? {
        willSet {
            if let url = newValue {
                avatar.setImage(with: url)
            }
        }
    }
    
    var communityName: String? {
        willSet {
            if let name = newValue {
                communityNameLabel.text = name
            }
        }
    }
    
    var communityNumber: String? {
        willSet {
            if let number = newValue {
                communityNumberLabel.text = "社区号：" + number
            }
        }
    }

    private lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        return container
    }()
    
    private lazy var avatar: UIImageView = {
        let avatar = UIImageView()
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 29
        avatar.contentMode = .scaleAspectFill
        avatar.backgroundColor = Asset.Colors.green55BD53.color
        return avatar
    }()
    
    private lazy var communityNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private lazy var communityNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.grayC4C4C4.color
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    private func createButton(_ image: UIImage, _ title: String, _ selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(Asset.Colors.black949494.color, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: -40, left: 16, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 40, left: -26, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.titleLabel?.textAlignment = .center
        return button
    }
    
    private lazy var notiButton: UIButton = {
        let button = createButton(Asset.Images.communityNotiIcon.image, "通知", #selector(notify))
        return button
    }()
    
    private lazy var mgrButton: UIButton = {
        let button = createButton(Asset.Images.communityMgrIcon.image, "管理", #selector(mgr))
        button.isHidden = !isOwner
        return button
    }()
    
    private lazy var quitCommunityFooterView: UIView = {
        let button = UIButton(type: .custom)
        button.setTitleColor(Asset.Colors.redD43030.color, for: .normal)
        button.setTitle("退出社区", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 64)
        button.addTarget(self, action: #selector(quit), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoView: UITableView = {
        let infoView = UITableView(frame: CGRect.zero, style: .plain)
        infoView.delegate = self
        infoView.dataSource = self
        infoView.showsVerticalScrollIndicator = false
        infoView.showsHorizontalScrollIndicator = false
        infoView.separatorStyle = .none
        infoView.isScrollEnabled = false
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayF6F6F6.color
        line.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 1)
        infoView.tableHeaderView = line
        infoView.register(RCSCCommunityManagerInfoCell.self, forCellReuseIdentifier: RCSCCommunityManagerInfoCell.reuseIdentifier)
        infoView.tableFooterView = isOwner ? nil : quitCommunityFooterView
        return infoView
    }()
    
    
    private lazy var dismissView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    var dataSource: Array<RCSCCommunityManagerPopActionType>!
    
    let communityDetail: RCSCCommunityDetailData
    
    var isOwner: Bool {
        get {
            return communityDetail.creator == RCSCUser.user?.userId
        }
    }
    
    init(communityDetail: RCSCCommunityDetailData) {
        self.communityDetail = communityDetail
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .popover
        dataSource = isOwner ? [.usersList, .nickName, .createGroup, .createChannel] : [.usersList, .nickName]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(communityDetailChanged), name: RCSCCommunityDetailChangedNotification,object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        guard let _ = container.layer.mask else {
            return container.rcscCorner(corners: [.topLeft, .topRight], radii: 30)
        }
    }
    
    @objc private func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    private func buildSubViews() {
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(460)
        }
        
        container.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 58, height: 58))
            make.top.equalToSuperview().offset(34)
            make.leading.equalToSuperview().offset(30)
        }
        
        container.addSubview(communityNameLabel)
        communityNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatar.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(avatar).offset(-14)
        }
        
        container.addSubview(communityNumberLabel)
        communityNumberLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatar.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(10)
            make.centerY.equalTo(avatar).offset(14)
        }
        
        if isOwner {
            container.addSubview(notiButton)
            notiButton.snp.makeConstraints { make in
                make.top.equalTo(avatar.snp.bottom).offset(36)
                make.leading.equalToSuperview().offset(80)
                make.size.equalTo(CGSize(width: 60, height: 80))
            }
            
            container.addSubview(mgrButton)
            mgrButton.snp.makeConstraints { make in
                make.top.equalTo(avatar.snp.bottom).offset(36)
                make.trailing.equalToSuperview().offset(-80)
                make.size.equalTo(CGSize(width: 60, height: 80))
            }
        } else {
            container.addSubview(notiButton)
            notiButton.snp.makeConstraints { make in
                make.top.equalTo(avatar.snp.bottom).offset(36)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 60, height: 80))
            }
        }
        
        
        container.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(notiButton.snp.bottom)
        }
        
        view.addSubview(dismissView)
        dismissView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(container.snp.top)
        }
    }
    
    @objc private func notify() {
        dismiss(animated: true) { [weak self] in
            guard let self = self, let block = self.dismissCompletion else { return }
            block(.notify)
        }
    }
    
    @objc private func mgr() {
        dismiss(animated: true) { [weak self] in
            guard let self = self, let block = self.dismissCompletion else { return }
            block(.manager)
        }
    }
    
    @objc private func quit() {
        showAlert(with: "退出社区") { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                guard let block = self.dismissCompletion else { return }
                block(.quit)
            }
        }
        
    }
    
    @objc private func communityDetailChanged(noti: Notification) {
        if let communityId = noti.object as? String, RCSCCommunityManager.manager.currentDetail.uid == communityId {
            RCSCCommunityDetailApi(communityId: communityId).fetch().success { object in
                if let object = object {
                    DispatchQueue.main.async {
                        self.avatarUrl = object.portrait ?? ""
                    }
                }
            }
        }
    }
}

extension RCSCCommunityManagerPopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityManagerInfoCell.reuseIdentifier, for: indexPath) as! RCSCCommunityManagerInfoCell
        cell.title = dataSource[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type: RCSCCommunityManagerPopActionType = RCSCCommunityManagerPopActionType(rawValue: indexPath.row)!
        dismiss(animated: true) { [weak self] in
            guard let self = self, let block = self.dismissCompletion else { return }
            block(type)
        }
    }
}

class RCSCCommunityManagerInfoCell: UITableViewCell {
    
    static var reuseIdentifier = "RCSCCommunityManagerInfoCellReuseIdentifier"
    
    var title: String? {
        willSet {
            if let title = newValue {
                titleLabel.text = title
            }
        }
    }
    
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = Asset.Colors.grayF6F6F6.color
        return line
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = Asset.Colors.black949494.color
        return label
    }()
    
    lazy var arrow: UIImageView = {
        let arrow = UIImageView(image: Asset.Images.arrowIcon.image)
        return arrow
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        buildSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildSubViews() {
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-30)
        }
    }
}
