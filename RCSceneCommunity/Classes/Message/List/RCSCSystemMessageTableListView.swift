//
//  RCSCSystemMessageTableListView.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/4/26.
//

import UIKit

import JXSegmentedView
import MJRefresh
import SVProgressHUD

class RCSCSystemMessageTableListView: UIView {
    
    private lazy var emptyView: UIView = {
        
        let emptyView = UIView()
        
        emptyView.backgroundColor = .white
        
        let iconView = UIImageView(image: Asset.Images.discoverEmptyIcon.image)
        emptyView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.size.equalTo(CGSize(width: 54, height: 46))
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black.alpha(0.4)
        titleLabel.text = "暂时无内容"
        emptyView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(12)
            make.centerX.equalTo(iconView)
        }
        
        let botomLineview: UIView = {
            let view = UIView()
            view.backgroundColor = Asset.Colors.grayEDEDED.color
            return view
        }()
        emptyView.addSubview(botomLineview)
        botomLineview.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        emptyView.isHidden = true
        
        return emptyView
    }()

    private lazy var tableView: UITableView = {
        let tableV = UITableView(frame: CGRect.zero, style: .plain)
        tableV.register(RCSCSysMsgAvatarHasGrantBtnCell.self, forCellReuseIdentifier: String(describing: RCSCSysMsgAvatarHasGrantBtnCell.self))
        tableV.register(RCSCSysMsgAvatarNormalCell.self, forCellReuseIdentifier: RCSCSysMsgAvatarNormalCell.reuseIdentifier)
        tableV.register(RCSCSysMsgAvatarGrantedShowCell.self, forCellReuseIdentifier: RCSCSysMsgAvatarGrantedShowCell.reuseIdentifier)
        tableV.register(RCSCSysMsgSysInfoNormalCell.self, forCellReuseIdentifier: RCSCSysMsgSysInfoNormalCell.reuseIdentifier)
        tableV.register(RCSCSysMsgSysInfoOnlyNoticeCell.self, forCellReuseIdentifier: RCSCSysMsgSysInfoOnlyNoticeCell.reuseIdentifier)
        tableV.showsVerticalScrollIndicator = false
        tableV.showsHorizontalScrollIndicator = false
        tableV.delegate = self
        tableV.dataSource = self
        tableV.backgroundView = emptyView
//        tableView.isScrollEnabled = false
        tableV.separatorStyle = .none
        tableV.estimatedRowHeight = 134
        tableV.rowHeight = UITableView.automaticDimension
        return tableV
    }()
    private var dataSourceArray = Array<RCMessage>()
    private var userInfoArray = Array<RCSCSysMsgUserInfo>() //需要二次请求,获取通知中的user信息
    private var page: Int = 0
//    let semaphore = DispatchSemaphore(value: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.leading.trailing.bottom.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        let botomLineview: UIView = {
            let view = UIView()
            view.backgroundColor = Asset.Colors.grayEDEDED.color
            return view
        }()
        addSubview(botomLineview)
        botomLineview.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header?.beginRefreshing()
        tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
//        tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer?.isAutomaticallyChangeAlpha = true
        
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveCommunitySystemMessage(notification:)), name: RCSCCommunityReceiveSystemMessageNotificationLocal, object: nil)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCommunitySystemMessage(notification:)), name: RCSCCommunityReceiveSystemMessageNotificationRCMicChannelNotice, object: nil)
        RCCoreClient.shared().add(self)
//        RCSCConversationMessageManager.setDelegate(delegate: self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func headerRefresh() {
        page = 0       
        dataSourceArray.removeAll()
        userInfoArray.removeAll()
        loadData()
    }
    
    @objc func footerRefresh() {
        page += 1
        loadMoreData()
    }

    private func loadMoreData(){
            if let msg = self.dataSourceArray.last {
                let lastMsgId = msg.messageId
                let queue = DispatchQueue(label: "com.rongcloud.RCSceneCommunitySysMsgsloadMoreData", attributes: .concurrent)
                queue.async {
                    RCSCSystemMessageManager().fetchSystemHistoryMessage(lastMsgId){ [weak self]  msgArr in
                         guard let self = self  else { return }
                       
                        if let msgArr = msgArr , msgArr.count > 0 {
//                             self.dataSourceArray.append(contentsOf: msgArr)
//                            self.semaphore.wait()
                            for  msg in msgArr {
                                if msg.objectName == "RCMic:CommunitySysNotice" {
                                    self.dataSourceArray.append(msg)
                                }
                            }
                            queue.async {
                                var userIds = [String]()
                                for sysMsg in self.dataSourceArray {
                                    if let sysMessage = sysMsg.content as? RCSCSystemMessage,
                                       let content = sysMessage.content {
                                        userIds.append(content.fromUserId ?? "")
                                    }
                                }
                                guard userIds.count > 0 else {
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                                        self.tableView.mj_footer?.isHidden = true
//                                        self.semaphore.signal()/
                                        return
                                    }
                                    
                                    return
                                }
                                
                                RCSCGetSysUserInfoApi(userIds).fetch().success { [weak self] object in
                                    guard let self = self else { return  }
                                    guard let repon = object else { return }
                                    for item in repon {
                                        self.userInfoArray.append(item)
                                    }
                                    self.tableView.reloadData()
                            
                                    if msgArr.count < 20 {
                                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                                        self.tableView.mj_footer?.isHidden = false
                                    }else{
                                        self.tableView.mj_footer?.endRefreshing()
                                    }
//                                    self.semaphore.signal()
                                  
                                }.failed { error in
                                    print("RCSCGetSysUserInfoApi -> \(error)")
                                    self.tableView.reloadData()
                                    self.tableView.mj_footer?.endRefreshing()
//                                    self.tableView.mj_footer?.isHidden = true
//                                    self.semaphore.signal()
                                }
     
                            }
                            
                             
                         }else {
                            if self.page == 0 {
                                 self.page = 0
                            }else{
                                self.page -= 1
                            }
                             DispatchQueue.main.async {
                                 self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                                 self.tableView.mj_footer?.isHidden = true
                             }
    
                         }
                     }
                }

          
            }else{
                DispatchQueue.main.async {
                    self.tableView.mj_footer?.endRefreshing()
//                    self.tableView.mj_footer?.isHidden = true
                }

            }
           
         
       
    }
    
    
    private func loadData() {
        let queue1 = DispatchQueue(label: "com.rongcloud.RCSceneCommunitySysMsgs", attributes: .concurrent)
        let queue2 = DispatchQueue(label: "com.rongcloud.RCSceneCommunitySysMsgsUserInfo", attributes: .concurrent)
        queue2.suspend()//队列挂起
      
        let workItem1 = DispatchWorkItem {
            RCSCSystemMessageManager().fetchInitializedHistoryMessage({ [weak self]  msgArr in
                 guard let self = self  else { return }
               
                 if let msgArr = msgArr , msgArr.count > 0 {
//                     self.semaphore.wait()
                     for  msg in msgArr {
                         if msg.objectName == "RCMic:CommunitySysNotice" {
                             self.dataSourceArray.append(msg)
                         }
                     }
                     print("dataSourceArray -> \(Thread.current)")
                     
                 }
                queue2.resume()
             })
            
        }
        
        let workItem2 = DispatchWorkItem{
            print("开始处理数据 \(Date())  thread: \(Thread.current)")
            var userIds = [String]()
            for sysMsg in self.dataSourceArray {
                if let sysMessage = sysMsg.content as? RCSCSystemMessage,
                   let content = sysMessage.content {
                    userIds.append(content.fromUserId ?? "")
                }
            }
            
            guard  userIds.count > 0 else {
 
                DispatchQueue.main.async {
//                    self.semaphore.signal()
                    self.tableView.reloadData()
                    self.tableView.mj_header?.endRefreshing()
                    return
                }
                return
            }
            RCSCGetSysUserInfoApi(userIds).fetch().success { [weak self] object in
                guard let self = self else { return  }
                guard let repon = object else { return }
                for item in repon {
                    self.userInfoArray.append(item)
                }
//                self.semaphore.signal()
                if self.dataSourceArray.count >= 20 {
                    self.tableView.mj_footer?.isHidden = false
                }
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
                print("UI刷新成功  \(Date())  thread: \(Thread.current)")
                print("数据处理完成 \(Date())  thread: \(Thread.current)")
            }.failed { error in
//                self.semaphore.signal()
                print("RCSCGetSysUserInfoApi -> \(error)")
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
            }
        }
        //异步执行
        queue1.async(execute: workItem1)
        //异步执行
        queue2.async(execute: workItem2)
//        self.tableView.mj_footer?.isHidden = false
    }
    
    @objc private func receiveCommunitySystemMessage(notification: Notification) {
       
        if let userInfo = notification.userInfo,
           let communityUid = userInfo[RCSCCommunitySystemMessageIdKey] as? String {
            for (index , sysMsgItem) in self.dataSourceArray.enumerated() {
                if  let sysMe = sysMsgItem.content as? RCSCSystemMessage,
                    let sysCont = sysMe.content ,
                    let typ = sysCont.type,
                    let comUid = sysCont.communityUid,
                    (typ == RCSCSystemMessageType.requestJoin)&&(communityUid == comUid) { //请求加入 &  communityUid 相同
                    print("🎉🎉🎉测试下")
                    sysMsgItem.extra = "1" ///同意
                    RCCoreClient.shared().setMessageExtra(sysMsgItem.messageId, value: "1") // 入库
                    self.dataSourceArray[index] = sysMsgItem
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        self.tableView.endUpdates()
                    }
                    break
                }
            }
        }
        
        
    }
}

extension RCSCSystemMessageTableListView: UITableViewDataSource,UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemCount = dataSourceArray.count
        emptyView.isHidden = itemCount != 0
        if !emptyView.isHidden {
            tableView.mj_footer?.isHidden = true
        }
        return itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  userInfoArray.count > indexPath.row else { return UITableViewCell() }
        let cellUserInfo:RCSCSysMsgUserInfo? = userInfoArray[indexPath.row]
        let cellMessageData = dataSourceArray[indexPath.row]
        let cellStyleData = RCMessage.msgConvertCellStyle(cellMessageData)
        switch cellStyleData {
            case .avatarNormal:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RCSCSysMsgAvatarNormalCell.self), for: indexPath) as! RCSCSysMsgAvatarNormalCell
            
            cell.cellModelData = (cellUserInfo,cellMessageData)
                return cell
                
            case .avatarHasGrantBtn:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RCSCSysMsgAvatarHasGrantBtnCell.self), for: indexPath) as! RCSCSysMsgAvatarHasGrantBtnCell
                cell.cellModelData = (cellUserInfo,cellMessageData)
                cell.didClickGrandRightBtn = { [weak self] (grandBool) in
                   
                    if grandBool { //agree
                        debugPrint("点击了同意")
                        cellMessageData.extra = "1"
                        self?.dataSourceArray[indexPath.row] = cellMessageData
                        self?.tableView.beginUpdates()
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self?.tableView.endUpdates()
                    }else{// reject
                        debugPrint("点击了拒绝")
                        cellMessageData.extra = "0"
                        self?.dataSourceArray[indexPath.row] = cellMessageData
                        self?.tableView.beginUpdates()
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self?.tableView.endUpdates()
                    }
                    
                }
            
            let sysMsg = cellMessageData
            if let sysMessage = sysMsg.content as? RCSCSystemMessage,
               let content = sysMessage.content, let communityUid = content.communityUid {
                guard let extraIntStr = cellMessageData.extra , extraIntStr != "0"  else {
                    debugPrint("cellMessageData.extra扩展:\(cellMessageData.extra)")
                    return cell
                }
                
                RCSCCommunityDetailApi(communityId: communityUid).fetch().success { object in
                    debugPrint("社区如果存在,查看社区用户的状态")
                    //社区如果存在,查看社区用户的状态
                    RCSCCommunityUserInfoApi(communityUid: communityUid, userUid: cellUserInfo?.userId ?? "" ).fetch().success { [weak self] object in
                        guard let `self` = self else { return }
                        guard let rCSCCommunityUserInfo = object  else { return }
                        if rCSCCommunityUserInfo.status == 3 { //已加入
                            cellMessageData.extra = "1"
                            RCCoreClient.shared().setMessageExtra(cellMessageData.messageId, value: "1") // 入库
                            self.dataSourceArray[indexPath.row] = cellMessageData
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            self.tableView.endUpdates()
                        }
                        
                        
                    }.failed { error in
                        if error.code != 10001 {
                            SVProgressHUD.showError(withStatus: "\(error.desc)")
                        }
                    }
                    
                    
                }.failed { [weak self] error in
                    if error.code == 10001 { //实测,删除后code 返回10001
                        debugPrint("社区ID:\(communityUid) 已不存在")
                        cellMessageData.extra = "0"
                        RCCoreClient.shared().setMessageExtra(cellMessageData.messageId, value: "0") // 入库
                        self?.dataSourceArray[indexPath.row] = cellMessageData
                        self?.tableView.beginUpdates()
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self?.tableView.endUpdates()
                    }else{
                        SVProgressHUD.showError(withStatus: "\(error.desc)")
                    }
                }
                
                
                
         
            }

 
            /*
                // 显示时候,判断,CommunityID 是否存在; 如果不存在 直接手动拒绝,拒绝
             RCSCCommunityListApi(pageNum: 1, pageSize: 1000).fetch().success { [weak self] object in
                 if let recordCommuitys = object?.records {
                     let sysMsg = cellMessageData
                       
                     if let sysMessage = sysMsg.content as? RCSCSystemMessage,
                        let content = sysMessage.content, let communityUid = content.communityUid{
                         let commuityiDArr:[String] = recordCommuitys.flatMap{ rCSCCommunityListRecord in
                             rCSCCommunityListRecord.communityUid
                         }
                         print("✨✨✨✨commuityiDArr:\(commuityiDArr)")
                         if !commuityiDArr.contains(communityUid) {
                             cellMessageData.extra = "0"
                            RCCoreClient.shared().setMessageExtra(cellMessageData.messageId, value: "0") // 入库
                             self?.dataSourceArray[indexPath.row] = cellMessageData
                             self?.tableView.beginUpdates()
                             self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                             self?.tableView.endUpdates()
                         }
                     }
                }
                 
             }
            */
                return cell
            case .avatarGrantedShow:
                let cell = tableView.dequeueReusableCell(withIdentifier: RCSCSysMsgAvatarGrantedShowCell.reuseIdentifier, for: indexPath) as! RCSCSysMsgAvatarGrantedShowCell
                cell.cellModelData = (cellUserInfo,cellMessageData)
                return cell
            case .sysInfoNormal:
                let cell = tableView.dequeueReusableCell(withIdentifier: RCSCSysMsgSysInfoNormalCell.reuseIdentifier, for: indexPath) as! RCSCSysMsgSysInfoNormalCell
                cell.cellModelData = (cellUserInfo,cellMessageData)
                return cell
                
                
            case .sysInfoOnlyNotice:
                let cell = tableView.dequeueReusableCell(withIdentifier: RCSCSysMsgSysInfoOnlyNoticeCell.reuseIdentifier, for: indexPath) as! RCSCSysMsgSysInfoOnlyNoticeCell
                cell.cellModelData = (cellUserInfo,cellMessageData)
                return cell
                
        }
        
      
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("\(indexPath.row) - > 被点击了") // 系统消息不可点击
    }
    
}

extension RCSCSystemMessageTableListView : JXSegmentedListContainerViewListDelegate{
    func listView() -> UIView {
        return self
    }

    func listDidAppear() {
        debugPrint("\(type(of: self))-> listDidAppear")
//        tableView.mj_header?.beginRefreshing()
    }
    
    func listDidDisappear() {
        debugPrint("\(type(of: self))-> listDidDisappear")
        
    }
    
}
extension RCSCSystemMessageTableListView {
    func insertMsg(_ message: RCMessage!){
        
//        semaphore.wait()
        
    
        let queue1 = DispatchQueue(label: "com.rongcloud.RCSceneCommunitySysMsgsonReceived", attributes: .concurrent)
        
        let queue2 = DispatchQueue(label: "com.rongcloud.RCSceneCommunitySysDel", attributes: .concurrent)
        queue1.suspend()//队列挂起
        let workItem1 = DispatchWorkItem{

            var userIds:[String] = {
                var userIDS = [String]()
                for userInfo in self.userInfoArray {
                    let userid = userInfo.userId
                    userIDS.append(userid)
                }
                return userIDS
            }()
            
            if let sysMsg = self.dataSourceArray.first {
                if let sysMessage = sysMsg.content as? RCSCSystemMessage,
                   let content = sysMessage.content {
                    userIds.insert(content.fromUserId ?? "", at: 0)
                }
            }
            
            RCSCGetSysUserInfoApi(userIds).fetch().success { [weak self] object in
                guard let self = self else { return  }
                guard let repon = object else { return }
                self.userInfoArray.removeAll()
                for item in repon {
                    self.userInfoArray.append(item)
                }
//                self.semaphore.signal()
                self.tableView.beginUpdates()
//                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.tableView.endUpdates()
                
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }.failed { error in
                print("RCSCGetSysUserInfoApi -> \(error)")
//                self.semaphore.signal()
                self.tableView.beginUpdates()
//                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.tableView.endUpdates()
                
            }
        }
        
        
        let workItem2 = DispatchWorkItem {
            self.dataSourceArray.insert(message, at: 0)
            if  let sysMsg = message, let sysMessage = sysMsg.content as? RCSCSystemMessage,
                let content = sysMessage.content,
                let type = content.type, type == RCSCSystemMessageType.dissolve { //当收到消息为解散社区时
                DispatchQueue.main.async {
                    if let communityUid = content.communityUid{
                        for (index , sysMsgItem) in self.dataSourceArray.enumerated() {
                            if  let sysMe = sysMsgItem.content as? RCSCSystemMessage,
                                let sysCont = sysMe.content ,
                                let typ = sysCont.type,
                                let comUid = sysCont.communityUid,
                                (typ == RCSCSystemMessageType.requestJoin)&&(communityUid == comUid) { //请求加入 &  communityUid 相同
                                print("🎉🎉🎉测试下是否进入选择")
                                sysMsgItem.extra = "0" ///拒绝
                                RCCoreClient.shared().setMessageExtra(sysMsgItem.messageId, value: "0") // 入库
                                self.dataSourceArray[index] = sysMsgItem
                                DispatchQueue.main.async {
                                    self.tableView.beginUpdates()
                                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                                    self.tableView.endUpdates()
                                }
                                break
                            }
                        }
                        queue1.resume()
                    }else{
                        queue1.resume()
                    }
                }
                
            }else{
                queue1.resume()
            }
        }
        queue2.async(execute: workItem2)
        queue1.async(execute: workItem1)
     
    }
}

extension RCSCSystemMessageTableListView: RCIMClientReceiveMessageDelegate{
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        if message.conversationType == .ConversationType_SYSTEM {
           
            insertMsg(message)
        }
    }
    
}

extension RCSCSystemMessageTableListView: RCSCConversationMessageManagerDelegate {
    func onReceivedSystem(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        insertMsg(message)
    }
}
