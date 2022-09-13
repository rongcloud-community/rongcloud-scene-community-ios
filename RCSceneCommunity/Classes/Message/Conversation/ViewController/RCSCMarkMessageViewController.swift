//
//  RCSCMarkMessageViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/5/12.
//

import UIKit
import RongIMLib
import MJRefresh
import SVProgressHUD

class RCSCMarkMessageViewController: UIViewController, UICollectionViewDelegate {
    
    let footer: MJRefreshAutoNormalFooter = {
        let footer = MJRefreshAutoNormalFooter()
        return footer
    }()
    
    @objc private func loadMore() {
        pageNum = pageNum + 1
        MsgMgr.fetchConversationMarkHistoryMessage(communityId: communityId, channelId: channelId, pageNum: pageNum, pageSize: pageSize, loadMore: true)
    }
    
    var refreshEnable = true {
        didSet {
            if !refreshEnable {
                collectionView.mj_header = nil
            }
        }
    }
    
    var loadMoreEnable = true {
        didSet {
            if !loadMoreEnable {
                collectionView.mj_footer = nil
            }
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: RCSceneMessageLayout()
        )
        view.dataSource = self
        view.backgroundColor = .white
        view.keyboardDismissMode = .onDrag
        view.backgroundView = emptyView
        view.mj_footer = footer
        
        return view
    }()
    
    private lazy var emptyView: UIView = {
        
        let emptyView = UIView()
        
        emptyView.backgroundColor = .white
        
        let iconView = UIImageView(image: Asset.Images.discoverEmptyIcon.image)
        emptyView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.size.equalTo(CGSize(width: 54, height: 46))
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black.alpha(0.4)
        titleLabel.text = "暂时无内容"
        emptyView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(4)
            make.centerX.equalTo(iconView)
        }
        
        emptyView.isHidden = true
        
        return emptyView
    }()
    
    let communityId: String
    
    var isCreator = false
    
    let channelId: String
    
    var messages = [RCSCMarkMessage]()
    
    var pageNum = 1
    
    let pageSize = 20
    
    var jumpToMessage:((RCSCMarkMessage) -> Void)?
    
    init(communityId: String, channelId: String) {
        self.communityId = communityId
        self.channelId = channelId
        super.init(nibName: nil, bundle: nil)
        RCSCConversationMessageManager.setDelegate(delegate: self)
        RCSCCommunityService.service.registerListener(listener: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "已标注消息"
        
        view.backgroundColor = .white
        
        buildSubViews()
        
        footer.isHidden = false
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadMore))
        
        fetchInitializeMessages()
    }
    
    private func buildSubViews() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
        collectionView.addGestureRecognizer(gesture)

    }
    
    private func fetchInitializeMessages() {
        MsgMgr.fetchConversationMarkHistoryMessage(communityId: communityId, channelId: channelId, pageNum: pageNum, pageSize: pageSize)
    }
    
    @objc private func longPressHandler(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        let message = messages[indexPath.row]
        markLongPressHandler(message)
    }
    
    func markLongPressHandler(_ message: RCSCMarkMessage) {
        let controller = RCSCActionSheetViewController(dataSource: isCreator ? [.jump, .remove] : [.jump])
        controller.didSelect = {[weak self] type in
            guard let self = self else { return }
            if type == .jump {
                guard let jumpToMessage = self.jumpToMessage else {
                    return
                }
                if let navigationController = self.navigationController {
                    for viewController in navigationController.viewControllers {
                        if viewController is RCSCConversationViewController {
                            navigationController.popToViewController(viewController, animated: true)
                            jumpToMessage(message)
                        }
                    }
                }

            } else {
                RCSCCommunityService.service.deleteMarkMessage(markMessage: message)
            }
        }
        present(controller, animated: true)
    }
}

extension RCSCMarkMessageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emptyView.isHidden = messages.count != 0
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        guard let message = RCSCConversationMessageManager.getMessageByUid(messageUid: message.messageUid),
              let content = message.content as? RCSCMessageProtocol
        else {
            return UICollectionViewCell()
        }
        
        let identifier = content.identifier()
        let cellClass = content.view()
        collectionView.register(cellClass, forCellWithReuseIdentifier: content.identifier())
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RCSCMessageBaseCell
        cell.contentTapHandler = { [weak self] message, type, sourceView in
            guard let self = self else { return }
            self.browseMedia(with: type, message: message, sourceView: sourceView)
        }
        
        let _ = cell.updateUI(message)
        
        let userInfo = RCSCUserInfoCacheManager.getUserInfo(with: message.targetId, userId: message.senderUserId ?? "", completion: nil)
            
        cell.nameString = userInfo?.nickName ?? ""
        cell.avatarString = userInfo?.portrait ?? ""
        
        return cell
    }
}

extension RCSCMarkMessageViewController: RCSCCommunityDataSourceDelegate {
    func deleteMarkMessageSuccess(_ markMessage: RCSCMarkMessage) {
        for index in 0..<messages.count {
            let message = messages[index]
            if message.uid == markMessage.uid {
                messages.remove(at: index)
                if messages.count == 0 {
                    collectionView.reloadData()
                } else {
                    let indexPath = IndexPath(row: index, section: 0)
                    collectionView.deleteItems(at: [indexPath])
                }
                break
            }
        }
    }
}
