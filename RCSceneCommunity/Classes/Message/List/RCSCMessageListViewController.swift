//
//  RCSCMessageListViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/29.
//

import UIKit
import JXSegmentedView
//import RongIMKit
import RongCloudOpenSource
import RongIMLib
import SVProgressHUD

let KPRIVATE_UnReadCount_Init = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])

let KSYSTEM_UnReadCount_Init = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_SYSTEM.rawValue])

open class RCSCMessageListViewController: RCSCBaseViewController, RCIMReceiveMessageDelegate {
    
    var segmentedViewSelectedItemAction:((Int) -> Void)?
    
    private let  titles =  ["私信","系统消息"]  // ->["私信","@我的","系统消息"]
    var numbers: [Int] = [Int(KPRIVATE_UnReadCount_Init),Int(KSYSTEM_UnReadCount_Init)]{
        willSet {
            let nums = newValue
            segmentedDataSource.numbers = nums
            segmentedView.reloadDataWithoutListContainer()
            let badgeValueNum = nums[0] + nums[1]
            if badgeValueNum > 0{
                self.tabBarController?.tabBar.showBadgeOnItemIndex(3)
            }else{
                self.tabBarController?.tabBar.hideBadgeOnItemIndex(3)
            }
        }
    }
    
    lazy var segmentedDataSource: JXSegmentedNumberDataSource = {
        let segDataSource = JXSegmentedNumberDataSource()
        segDataSource.isTitleColorGradientEnabled = false
        segDataSource.titleNormalColor = Asset.Colors.black000000.color.alpha(0.3)
        segDataSource.titleSelectedColor = Asset.Colors.black000000.color
        segDataSource.titleNormalFont = UIFont.systemFont(ofSize: 18, weight: .regular)
        segDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 18, weight: .regular)
        segDataSource.isTitleZoomEnabled = false
        segDataSource.isTitleStrokeWidthEnabled = true
        segDataSource.isSelectedAnimable = true
        segDataSource.isItemSpacingAverageEnabled = false
        segDataSource.itemSpacing = 26
        segDataSource.titles = titles
        segDataSource.numbers = numbers
        segDataSource.numberStringFormatterClosure = { (number) -> String in
            if number > 99 {
                return "99+"
            }
            return "\(number)"
        }
        segDataSource.numberBackgroundColor = Asset.Colors.pinkF31D8A.color
        return segDataSource
    }()
    lazy var segmentedView: JXSegmentedView = {
        let segView = JXSegmentedView()
        segView.delegate = self
      
        segView.dataSource = segmentedDataSource
        
        segView.contentEdgeInsetLeft = 29
        segView.contentEdgeInsetRight = 29
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.lineStyle = .normal
        
        indicator.indicatorWidth = 18
        indicator.indicatorColor = Asset.Colors.black000000.color
        segView.indicators = [indicator]
        return segView
    }()
    lazy var listContainerView: JXSegmentedListContainerView = {
        let listContainerView = JXSegmentedListContainerView(dataSource: self)
        return listContainerView
    }()
    
  
    
    lazy var topView: UIView = {
        let view = UIView(frame:CGRect.init(x: 0, y: UIDevice.vg_statusBarHeight(), width: kScreenWidth, height: UIDevice.vg_navigationBarHeight()))
        view.backgroundColor = .white
        return view
    }()
    
    var dataSource:Array<String> = []
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        RCSCCommunityService.service.registerListener(listener: self)
        buildSubViews()
        var numsDatas = self.numbers
        
        let count0 = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        numsDatas[0] = Int(count0)
         
        let count1 = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_SYSTEM.rawValue])
        numsDatas[1] = Int(count1)
        
        self.numbers = numsDatas
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        var numsDatas = self.numbers

        let count0 = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        numsDatas[0] = Int(count0)
         
        let count1 = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_SYSTEM.rawValue])
        numsDatas[1] = Int(count1)
        
        self.numbers = numsDatas
    }

 
    
    public func resetLoad() {
        listContainerView.reloadData()
        segmentedView.selectItemAt(index: 0)
    }
    
    private func buildSubViews() {

        setJXSegmentUI()
        //模拟角标数字刷新
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.numbers = [5,100]
//        }
//        RCIM.shared().addReceiveMessageDelegate(self)
//        RCIMClient.shared().setReceiveMessageDelegate(self, object: nil)
        RCCoreClient.shared().add(self)
    }

    
    
    func setJXSegmentUI(){
        view.addSubview(topView)
        topView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
        //设置可滚动的listContainerView
        view.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalToSuperview() //.offset(-UIDevice.vg_tabBarFullHeight())
        }
        segmentedView.contentScrollView = listContainerView.scrollView
        self.segmentedDataSource.reloadData(selectedIndex: 0)
        //接受通知数
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(notificationRefreshAction),
                                       name: NSNotification.Name(rawValue: "ConversationType_PRIVATE_onSelectedTableRow"),
                                       object: nil)
    }
}

extension RCSCMessageListViewController: JXSegmentedViewDelegate,JXSegmentedListContainerViewDataSource {
    public func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        segmentedDataSource.titles.count
    }
    
    public func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let listContainerRect = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - topView.frame.minY - UIDevice.vg_tabBarFullHeight())
        switch index {
        case 0:
//            var indexView : RCSCPrivateMessageTableListView
//            indexView = RCSCPrivateMessageTableListView(frame: listContainerRect)
//            return indexView
            var indexVc: RCSCPrivateMsgChatListVC
            indexVc = RCSCPrivateMsgChatListVC.init(.ConversationType_PRIVATE)
            return indexVc
            
        case 1:
            var indexView : RCSCSystemMessageTableListView
            indexView = RCSCSystemMessageTableListView(frame: listContainerRect)
            return indexView
        
        default:
            var indexView : RCSCSystemMessageTableListView
            indexView = RCSCSystemMessageTableListView(frame: listContainerRect)
            return indexView
        }
        
    }
    
    public func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {

        //传递didClickSelectedItemAt事件给listContainerView，必须调用！！！
        listContainerView.didClickSelectedItem(at: index)
        cleanUnreadSysMsg()

    }
    
    public func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int){
        listContainerView.didClickSelectedItem(at: index)
        cleanUnreadSysMsg()
        
    }
    
    private func cleanUnreadSysMsg(_ index:  Int = 1){
        if index == 1 { //如果是系统消息
            if numbers[1] != 0 { // 如果有消息的话.才调用clear
                var numsDatas = self.numbers
                numsDatas[1] = 0
                self.numbers = numsDatas
                let isClearStatus = RCIMClient.shared().clearMessagesUnreadStatus(.ConversationType_SYSTEM, targetId: "_SYSTEM_")
                 if isClearStatus {
                    print("系统消息,全部已读")
                 }else {
                     SVProgressHUD.showInfo(withStatus: "clearMessagesUnreadStatus 异常,请刷新后再试")
                 }
            }
        }
    }
    
    //MARK: - 点击私信后刷新角标
    @objc private func notificationRefreshAction(noti: Notification) {
        var numsDatas = self.numbers
        let count = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        numsDatas[0] = Int(count)
        self.numbers = numsDatas
        print("notificationRefreshAction->\(noti)")
    }
    
    
}


extension RCSCMessageListViewController:RCIMClientReceiveMessageDelegate{
    public func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        guard let msg = message, msg.conversationType == .ConversationType_PRIVATE || msg.conversationType == .ConversationType_SYSTEM else {
            return
        }
        DispatchQueue.main.async {
            var numsDatas = self.numbers
            if msg.conversationType == .ConversationType_PRIVATE {
                let count = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
                numsDatas[0] = Int(count)
            } else {
                let count = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_SYSTEM.rawValue])
                numsDatas[1] = Int(count)
            }
            self.numbers = numsDatas
        }
    }
}
