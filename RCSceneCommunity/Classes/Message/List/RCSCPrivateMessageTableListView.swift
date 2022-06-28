//
//  RCSCPrivateMessageTableListView.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/4/27.
//

import UIKit
import JXSegmentedView
import MJRefresh
import SVProgressHUD
import TableViewDragger

class RCSCPrivateMessageTableListView: UIView {
    
    private lazy var tableView: UITableView = {
        let tableV = UITableView(frame: CGRect.zero , style: .plain)
        tableV.register(RCSCPrivateMessageCell.self, forCellReuseIdentifier: RCSCPrivateMessageCell.reuseIdentifier)
        tableV.showsVerticalScrollIndicator = false
        tableV.showsHorizontalScrollIndicator = false
        tableV.delegate = self
        tableV.dataSource = self
        tableV.separatorStyle = .none
        tableV.estimatedRowHeight = 134
        tableV.rowHeight = UITableView.automaticDimension
        return tableV
    }()
    private var dataSourceArray = [NSObject]() {
        willSet {
//            let dataArray = newValue
            tableView.reloadData()
        }
    } //FIXME: 待定消息消息数据类型
    private var page: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var tabFrame = frame
        tabFrame.origin.y = 20
        tableView.frame  = tabFrame
        addSubview(tableView)
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
//        tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
//        tableView.mj_footer?.isAutomaticallyChangeAlpha = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func headerRefresh() {
        SVProgressHUD.show()
        page = 0
       
        dataSourceArray.removeAll()
        loadData()
    }
    
    @objc func footerRefresh() {
        page += 1
        loadData()
    }

    private func loadData() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            debugPrint("模拟数据加载延迟0.25")
            SVProgressHUD.dismiss()
            self.tableView.mj_header?.endRefreshing()
        }
    }
}



extension RCSCPrivateMessageTableListView: UITableViewDataSource,UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count==0 ? 5 : dataSourceArray.count //FIXME: 模拟测试
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCPrivateMessageCell.reuseIdentifier, for: indexPath) as! RCSCPrivateMessageCell
        cell.setCellModel(nil) //FIXME: 模拟测试
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("\(indexPath.row) - > 被点击了") //TODO: 待扩展点击逻辑
    }
    
}

extension RCSCPrivateMessageTableListView : JXSegmentedListContainerViewListDelegate{
    func listView() -> UIView {
        return self
    }

    func listDidAppear() {
        debugPrint("\(type(of: self))-> listDidAppear")
    }
    
    func listDidDisappear() {
        debugPrint("\(type(of: self))-> listDidDisappear")
    }
    
}
