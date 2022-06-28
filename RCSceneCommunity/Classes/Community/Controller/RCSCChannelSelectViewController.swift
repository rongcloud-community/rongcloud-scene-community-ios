//
//  RCSCChannelSelectViewController.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/28.
//

import UIKit
import SVProgressHUD
enum RCSCChannelSelectFormSourceType: Int {
    case formDefaultChannel = 1
    case fromSystemMessageChannel = 2
}

class RCSCChannelSelectViewController: UIViewController {
    var needRefreshDetail: ((String) -> Void)?
    private var fromSoure:RCSCChannelSelectFormSourceType
    private var detailData = RCSCCommunityManager.manager.currentDetail
    private var recordjoinChannelUid:String?
    private var recordmsgChannelUid:String?
    private var selectChannelName:String?
    private var selectChannelUid:String?
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.register(RCSCCommunityDetailListCell.self, forCellReuseIdentifier: RCSCCommunityDetailListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = Asset.Colors.grayEDEDED.color
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 28))
        header.backgroundColor = Asset.Colors.grayF4F6FA.color
        tableView.tableHeaderView = header
        return tableView
    }()
    
    init(_ fromSoure: RCSCChannelSelectFormSourceType) {
        self.fromSoure = fromSoure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RCSCCommunityManager.manager.registerListener(listener: self)
        title = "选择频道"
        view.backgroundColor = .white
        buildSubViews()
        
        switch fromSoure {
        case .formDefaultChannel:
            recordjoinChannelUid = detailData.joinChannelUid
            selectChannelUid = recordjoinChannelUid
        case .fromSystemMessageChannel:
            recordmsgChannelUid = detailData.msgChannelUid
            selectChannelUid = recordmsgChannelUid
        }
    }
    
    private func buildSubViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func updateChannelSetting() {
        let pram:[String: Any]
        switch fromSoure {
        case .formDefaultChannel:
            guard let selectChannelName = selectChannelName ,
                  let recordjoinChannelUid = recordjoinChannelUid else {
                return
            }
            pram = ["joinChannelUid" : detailData.joinChannelUid]
            RCSCCommunityManager.manager.service.updateCommunity(communityId: detailData.uid, param: pram)
         
        case .fromSystemMessageChannel:
            guard let selectChannelName = selectChannelName ,
                  let recordmsgChannelUid = recordmsgChannelUid else {
                return
            }
            pram = ["msgChannelUid" : detailData.msgChannelUid]
            RCSCCommunityManager.manager.service.updateCommunity(communityId: detailData.uid, param: pram)
        }
    }
}

extension RCSCChannelSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailData.groupList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let on =  detailData.groupList[section].on {
            return on ? detailData.groupList[section].channelList.count : 0
        }else{
            return detailData.groupList[section].channelList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RCSCCommunityDetailListCell.reuseIdentifier, for: indexPath) as! RCSCCommunityDetailListCell
        cell.name = detailData.groupList[indexPath.section].channelList[indexPath.row].name
        cell.contentView.backgroundColor = .white
        return  cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = RCSCSectionToolHeader(openEnable: true)
        sectionHeader.sectionName = detailData.groupList[section].name //"分组\(section)"
        sectionHeader.section = section
        sectionHeader.on = detailData.groupList[section].on ?? true
        sectionHeader.groupOpenHandler = {[weak self] section in
            guard let self = self else {return}
//            self.dataSource[section].on = !(self.dataSource[section].on ?? true)
            self.detailData.groupList[section].on = !(self.detailData.groupList[section].on ?? true)
            tableView.reloadSections([section], with: .fade)
        }
        sectionHeader.disableCreate = true
        sectionHeader.backgroundColor = .white
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = detailData.groupList[indexPath.section].channelList[indexPath.row]
        let channelUid = channel.uid
       
        if fromSoure == RCSCChannelSelectFormSourceType.formDefaultChannel {
            detailData.joinChannelUid = channelUid
            selectChannelUid = channelUid
            selectChannelName = channel.name

        } else  if fromSoure == RCSCChannelSelectFormSourceType.fromSystemMessageChannel{
            detailData.msgChannelUid = channelUid
            selectChannelUid = channelUid
            selectChannelName = channel.name
        }
        
        updateChannelSetting()
    }
}


extension RCSCChannelSelectViewController: RCSCCommunityDataSourceDelegate {
    func updateCommunityInfo(_ isSuccess: Bool){
        SVProgressHUD.dismiss()
        if isSuccess {
            switch fromSoure {
            case .formDefaultChannel:
                SVProgressHUD.showSuccess(withStatus: "默认进入频道更新成功")
                RCSCCommunityManager.manager.currentDetail.joinChannelUid = selectChannelUid!
                if let needRefreshDetail = needRefreshDetail {
                    needRefreshDetail(selectChannelName!)
                }
            case .fromSystemMessageChannel:
                SVProgressHUD.showSuccess(withStatus: "系统消息频道更新成功")
                RCSCCommunityManager.manager.currentDetail.msgChannelUid = selectChannelUid!
                if let needRefreshDetail = needRefreshDetail {
                    needRefreshDetail(selectChannelName!)
                }
            }
//            navigationController?.popViewController(animated: true)
        }else{
            SVProgressHUD.showError(withStatus: "服务异常,请稍后重试")
        }
        
    }
}
