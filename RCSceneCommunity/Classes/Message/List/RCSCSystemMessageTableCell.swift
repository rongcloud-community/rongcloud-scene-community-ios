//
//  RCSCSystemMessageTableCell.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/4/25.
//

import UIKit
import CoreData
//import RongIMKit
import RongCloudOpenSource
import SVProgressHUD

enum RCSCSystemMessageTableCellStyle {
    case avatarNormal /// 普通样式: 时间,通知标题,通知副标
    case avatarHasGrantBtn // 普通样式基础上,加显一组 同意 拒绝 按钮
    case avatarGrantedShow //  普通样式基础上,加显: 已同意/已拒绝 lab
    case sysInfoNormal //普通样式基础上,移除头像 换本地sysInfo
    case sysInfoOnlyNotice //  仅仅只有提示消息
    
}

class RCSCSysMsgAvatarNormalCell:RCSCSystemMessageTableCell{
    static let reuseIdentifier = String(describing: RCSCSysMsgAvatarNormalCell.self)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    private func buildSubViews(){

        contentView.addSubview(avatarImgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
       
        
        avatarImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(avatarImgView)
            make.height.equalTo(20)
        }
        
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-20).priority(.high)
            make.leading.equalTo(titleLabel.snp.trailing).offset(20).priority(.low)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(titleLabel.snp.bottom).offset(4.5)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal) //宽度不够时，可以被压缩
        titleLabel.setContentHuggingPriority(.required, for: .horizontal) //抱紧，类似于sizefit，不会根据父view长度变化
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal) //不可以被压缩，尽量显示完整
        
        
    }
}

class RCSCSysMsgAvatarHasGrantBtnCell:RCSCSystemMessageTableCell{
    static let reuseIdentifier = String(describing: RCSCSysMsgAvatarHasGrantBtnCell.self)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveCommunitySystemMessage(notification:)), name: RCSCCommunityReceiveSystemMessageNotificationLocal, object: nil)
        buildSubViews()
        
    }
    private func buildSubViews(){

        contentView.addSubview(avatarImgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(grantView)
        
        avatarImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(avatarImgView)
            make.height.equalTo(20)
        }
        
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-20).priority(.high)
            make.leading.equalTo(titleLabel.snp.trailing).offset(20).priority(.low)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(titleLabel.snp.bottom).offset(4.5)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-54)
        }
        
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal) //宽度不够时，可以被压缩
        titleLabel.setContentHuggingPriority(.required, for: .horizontal) //抱紧，类似于sizefit，不会根据父view长度变化
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal) //不可以被压缩，尽量显示完整
        
        grantView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.height.equalTo(34)
        }
        
    }
    /*
    @objc private func receiveCommunitySystemMessage(notification: Notification) {
        if let type = notification.object as? RCSCSystemMessageType {
            switch type {
            case  .joined:
                guard let userInfo = notification.userInfo,
                      let communityUid = userInfo[RCSCCommunitySystemMessageIdKey] as? String
                else { return }
                if  let sysMsgItem = self.messageData,
                    let sysMe = sysMsgItem.content as? RCSCSystemMessage,
                    let sysCont = sysMe.content ,
                    let typ = sysCont.type,
                    let comUid = sysCont.communityUid,
                    communityUid == comUid { //请求加入 &  communityUid 相同
                    self.autoToAgreeBtn()
                }
                
                break
            default:
                break
            }
        }
    }
    */
}

class RCSCSysMsgAvatarGrantedShowCell:RCSCSystemMessageTableCell{
    static let reuseIdentifier = String(describing:  RCSCSysMsgAvatarGrantedShowCell.self)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    private func buildSubViews(){
        
        contentView.addSubview(avatarImgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(showGrantedLel)
        
        
        avatarImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(avatarImgView)
            make.height.equalTo(20)
        }
        
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-20).priority(.high)
            make.leading.equalTo(titleLabel.snp.trailing).offset(20).priority(.low)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(titleLabel.snp.bottom).offset(4.5)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-44)
        }
        
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal) //宽度不够时，可以被压缩
        titleLabel.setContentHuggingPriority(.required, for: .horizontal) //抱紧，类似于sizefit，不会根据父view长度变化
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal) //不可以被压缩，尽量显示完整
        
        showGrantedLel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-24)
            make.leading.equalTo(descLabel)
            make.height.equalTo(22)
        }
    }
}


class RCSCSysMsgSysInfoNormalCell:RCSCSystemMessageTableCell{
    static let reuseIdentifier = String(describing:  RCSCSysMsgSysInfoNormalCell.self)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    private func buildSubViews(){
        
        contentView.addSubview(avatarImgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
        
        
        avatarImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(avatarImgView)
            make.height.equalTo(20)
        }
        
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-20).priority(.high)
            make.leading.equalTo(titleLabel.snp.trailing).offset(20).priority(.low)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.top.equalTo(titleLabel.snp.bottom).offset(4.5)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal) //宽度不够时，可以被压缩
        titleLabel.setContentHuggingPriority(.required, for: .horizontal) //抱紧，类似于sizefit，不会根据父view长度变化
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal) //不可以被压缩，尽量显示完整
        
        
    }
}


class RCSCSysMsgSysInfoOnlyNoticeCell:RCSCSystemMessageTableCell{
    static let reuseIdentifier = String(describing:  RCSCSysMsgSysInfoOnlyNoticeCell.self)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildSubViews()
    }
    private func buildSubViews(){
        
        contentView.addSubview(avatarImgView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
        
        
        avatarImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 54, height: 54))
            make.bottom.equalToSuperview().offset(-18)
        }
 
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImgView.snp.trailing).offset(11)
            make.centerY.equalTo(avatarImgView)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImgView)
            make.height.equalTo(16)
            make.trailing.equalToSuperview().offset(-20).priority(.high)
            make.leading.equalTo(descLabel.snp.trailing).offset(20).priority(.low)
        }
        
 
        
        descLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal) //宽度不够时，可以被压缩
        descLabel.setContentHuggingPriority(.required, for: .horizontal) //抱紧，类似于sizefit，不会根据父view长度变化
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal) //不可以被压缩，尽量显示完整
        
        
    }
}


class RCSCSystemMessageTableCell: UITableViewCell {
    
    //MARK: -  lazy property
    lazy var avatarImgView: UIImageView = {
        let imgV = UIImageView()
        imgV.layer.masksToBounds = true
        imgV.layer.cornerRadius = 27
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Asset.Colors.black282828.color
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = Asset.Colors.black282828.color.alpha(0.2)
        label.textAlignment = .right
        return label
    }()
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = Asset.Colors.black282828.color.alpha(0.54)
        label.numberOfLines = 2
        return label
    }()
    lazy var rejectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame =  CGRect.init(x: kScreenWidth - 28 - 82*2 - 10 ,y: 0, width: 82, height: 34)
        btn.backgroundColor = Asset.Colors.grayF3F4F5.color
        btn.setTitle("拒绝", for: .normal)
        btn.setTitleColor(Asset.Colors.black020037.color, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 17
        btn.addTarget(self, action: #selector(respondsToRejectBtn), for: .touchUpInside)
        return btn
    }()
    lazy var agreeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame =  CGRect.init(x: kScreenWidth - 28 - 82, y: 0, width: 82, height: 34)
        btn.backgroundColor = Asset.Colors.blue72BEF8.color
        
        btn.setTitle("同意", for: .normal)
        btn.setTitleColor(Asset.Colors.whiteFFFFFF.color, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 17
        btn.addTarget(self, action: #selector(respondsToAgreeBtn), for: .touchUpInside)
        return btn
    }()
    lazy var showGrantedLel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = Asset.Colors.black020037.color
        label.textAlignment = .right
        return label
    }()
    lazy var grantView: UIView = {
        let view = UIView()
        view.bounds = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 34)
        view.backgroundColor = Asset.Colors.whiteFFFFFF.color //.white
        view.addSubview(rejectBtn)
        view.addSubview(agreeBtn)
        return view
    }()
    
    // MARK: - Computed Property
    var titleText: String? {
        willSet {
            guard let text = newValue else { return  }
            titleLabel.text = text
        }
    }
    var timeLabText: String? {
        willSet {
            guard let text = newValue else { return  }
            timeLabel.text = text
        }
    }
    
    var descLabText: String? {
        willSet {
            guard let text = newValue else { return  }
            descLabel.text = text
        }
    }
    
    var showGrantStatus: String?{
        willSet {
            guard let text = newValue else { return  }
            showGrantedLel.text = text
        }
    }
    

    /// ture 同意
    var didClickGrandRightBtn:((Bool) -> Void)?
    

    
 
    var cellStyle: RCSCSystemMessageTableCellStyle = .avatarNormal
    var cellUserInfo:RCSCSysMsgUserInfo?
    
    var messageData: RCMessage?{
        willSet {
            guard let message = newValue else { return }
            let cellId = message.messageId
            //注意先赋值 cellUserInfo
            let title = cellUserInfo?.userName
            let avatarStr = cellUserInfo?.portrait
            let timeTitle = RCKitUtility.convertConversationTime(message.sentTime/1000) ?? ""
            if let sysMessage = message.content as? RCSCSystemMessage,
               let content = sysMessage.content {
                let subTitle = content.message
//   let type = content.type //0代表申请加入社区、1代表加入社区后通知消息、2代表退出社区的通知消息，3代表被踢出社区的通知消息
                let sytle = RCMessage.typeConvertCellStyle(content.type?.rawValue)
                cellStyle = sytle

                if let eExtra = message.extra , eExtra.count > 0 {
                   showGrantStatus = (eExtra == "1" ) ? "已同意" : "已拒绝"
                   cellStyle = .avatarGrantedShow //本地维护的状态
               }else{
                   showGrantStatus = nil
                   cellStyle = sytle
               }
                
                cellData = (cellId,title,subTitle,timeTitle,avatarStr,cellStyle,showGrantStatus)
            }
        }
    }
    
    
    public var cellModelData: (cellUserInfo:RCSCSysMsgUserInfo?,messageData: RCMessage?) {
        willSet {
            self.cellUserInfo = newValue.cellUserInfo
            self.messageData = newValue.messageData
            
        }
    }
    
    
    
    var cellData: (cellId: Int,title: String?, subTitle: String?, timeTitle: String,avatarStr: String?, cellStyleData :RCSCSystemMessageTableCellStyle, showGrandStatus: String?)?  {
        willSet{
            if let data = newValue {
              
                cellStyle = data.cellStyleData
                timeLabText = data.timeTitle
                descLabText = data.subTitle
                showGrantStatus = data.showGrandStatus
                if cellStyle == .sysInfoNormal || cellStyle == .sysInfoOnlyNotice {
                    avatarImgView.image = Asset.Images.sysnoticeInfoIcon.image
                    titleText = "系统提示"
                }else{
                    titleText = data.title
                    guard let imagUrl = data.avatarStr else { return }
                    guard  !imagUrl.isEmpty else{
                        let defaultImagUrl = RCSCDefaultAvatar
                        avatarImgView.setImage(with: defaultImagUrl)
                        return
                    }
                    avatarImgView.setImage(with: imagUrl.handeAvatarFullPath())
                }
            }
        }
    }
    
    
 
    
  
 
    


    // MARK: - respondsMethod

    @objc func respondsToRejectBtn() {

        updateCommunityUser("0") { [weak self] in
            guard let self = self else { return }
            self.showGrantStatus = "已拒绝"
            RCCoreClient.shared().setMessageExtra(self.messageData!.messageId, value: "0")
        }
        if let action = didClickGrandRightBtn {
            action(false)
        }
    }
    
    @objc func respondsToAgreeBtn() {

        updateCommunityUser("1") { [weak self] in
            guard let self = self else { return }
            self.showGrantStatus = "已同意"
            RCCoreClient.shared().setMessageExtra(self.messageData!.messageId, value: "1")
        }
        if let action = didClickGrandRightBtn {
            action(true)
        }
    }
    
    
    func autoToAgreeBtn() {
        self.showGrantStatus = "已同意"
        RCCoreClient.shared().setMessageExtra(self.messageData!.messageId, value: "1")
        if let action = didClickGrandRightBtn {
            action(true)
        }
    }
    
    
    func updateCommunityUser(_ showGrantStatus: String,completed: (() -> (Void))?){
        let status : Int = (showGrantStatus == "1") ? 3: 2 //同意1 拒绝 0 对应的是status 3 和2 -> 同安卓对齐
        if let sysMessage = messageData?.content as? RCSCSystemMessage,
            let content = sysMessage.content,
            let communityUid = content.communityUid ,
            let fromUserId = content.fromUserId {
            SVProgressHUD.show()
            RCSCUpdateCommunityUserAPI(communityUid: communityUid, userUid: fromUserId, status: status).fetch().success { object in
                SVProgressHUD.dismiss()
                if let completed = completed {
                    completed()
                }
            }.failed { error in
                SVProgressHUD.dismiss()
                print("失败 -> \(error)")
            }
        }
        
    }
   
    //MARK: - pubilc Methodist
  

//    public func setCellModel(_ rcMsg:RCMessage?) {
        //TODO: 可根据数据模型进行数据映射
        //模拟数据
//        cellData = ("cellId","Annette Black"," @所有人 大家快帮我看看这关 怎么过？！你确定上次见到的是我吗？","02:30 pm","https://tva1.sinaimg.cn/large/e6c9d24ely1h1o46t3sbij201o01ojr5.jpg",.normal)
//        if let rcMsg = rcMsg {
//            let cellId = rcMsg.messageId
//            let userInfo = RCSCUser.user
//            cellData = (rcMsg.messageId,userInfo?.userName,userInfo?.portrait,rcMsg.content)
//        }
//    }


    //MARK: - private Methodist

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    

}


extension RCMessage {
    
     static func msgConvertCellStyle(_ message:RCMessage) -> RCSCSystemMessageTableCellStyle {
        if let sysMessage = message.content as? RCSCSystemMessage,
           let content = sysMessage.content {
            var sytle = typeConvertCellStyle(content.type?.rawValue)
            let recSytle = sytle
            
            if let eExtra = message.extra , eExtra.count > 0 {
               sytle = .avatarGrantedShow //本地维护的状态
           }else{
               sytle = recSytle
           }
           return sytle
        }
        return .sysInfoOnlyNotice
    }
    
    //  FIXME: 设计稿和API未能匹配
  static func typeConvertCellStyle(_ type: Int?) -> RCSCSystemMessageTableCellStyle{
        guard let type = type else { return .sysInfoOnlyNotice }
        switch type {
            /*
             "type":0代表申请加入社区、1代表加入社区后通知消息、2代表退出社区的通知消息，
            3代表被踢出社区的通知消息,4代表被禁言，5代表解除禁言，6代表被拒绝加入,7代表解散社区
             */
        case 0:
            return .avatarHasGrantBtn
        case 1,2:
            return .sysInfoOnlyNotice //.avatarNormal //FIXME: QA 最新需求解释:加入或退出社区，属于系统提示，不应显示个人信息
        case 3,4,5,6:
            return .sysInfoOnlyNotice
        case 7:
            return .sysInfoNormal
        default:
            return .sysInfoNormal
        }
    }
    
}


