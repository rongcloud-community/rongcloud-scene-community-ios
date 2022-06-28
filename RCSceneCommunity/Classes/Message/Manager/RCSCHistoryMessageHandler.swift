//
//  RCSCHistoryMessageHandler.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/13.
//

import Foundation
import SVProgressHUD
import RongCloudOpenSource

class RCSCHistoryMessageHandler: NSObject {
    
    weak var delegate: RCSCConversationMessageManagerDelegate?
    
    private let channelClient = RCChannelClient.sharedChannelManager()!
    
    private let coreClient = RCCoreClient.shared()!
    
    func fetchConversationInitializedHistoryMessage(communityId:String, channelId: String, conversation: RCConversation?) {
        var sendTime = Int64(Date().timeIntervalSince1970 * 1000)
        if let conversation = conversation {
            sendTime = conversation.sentTime
        }
        let option = RCHistoryMessageOption()
        option.recordTime = sendTime + 1
        option.count = 20
        option.order = RCHistoryMessageOrderDesc
        channelClient.getMessages(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, option: option) { messages, timestamp, isRemaining, code in
            DispatchQueue.main.async {
                if let messages = messages as? Array<RCMessage> {
                    self.delegate?.onFetchHistoryMessagesSuccess(messages: messages.reversed(), strategy: .before)
                }
            }
        } error: { code in
            SVProgressHUD.showError(withStatus: "获取历史聊天记录失败 code:\(code)")
        }
    }
    
    func fetchHistoryMessage(communityId:String, channelId: String, sendTime: Int64, strategy: RCSCFetchMessageStrategy, fix: Bool) {
        let option = RCHistoryMessageOption()
        option.recordTime = sendTime
        option.count = 20
        option.order = strategy == .before ? RCHistoryMessageOrderDesc : RCHistoryMessageOrderAsc
        channelClient.getMessages(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId, option: option) { messages, timestamp, isRemaining, code in
            DispatchQueue.main.async {
                if let messages = messages as? Array<RCMessage> {
                    if strategy == .before {
                        //上拉，加载之前的聊天记录
                        //以发送时间降序数组 需要翻转
                        self.delegate?.onFetchHistoryMessagesSuccess(messages: messages.reversed(), strategy: strategy)
                    } else if strategy == .after {
                        self.delegate?.onFetchHistoryMessagesSuccess(messages: messages, strategy: strategy)
                    }
                } else {
                    self.delegate?.onFetchHistoryMessagesSuccess(messages: [], strategy: strategy)
                }
            }
        } error: { code in
            SVProgressHUD.showError(withStatus: "获取历史聊天记录失败 code:\(code)")
        }
    }
    
    func fetchMessageByMessageUid(messageUid: String) -> RCMessage? {
        return coreClient.getMessageByUId(messageUid)
    }
    
    func fetchMarkMessageList(channelUid: String, pageNum: Int, pageSize: Int, loadMore: Bool) {
        RCSCCommunityMarkMessageListApi(channelUid: channelUid, pageNum: pageNum, pageSize: pageSize).fetch().success {[weak self] object in
            guard let self = self, let records = object?.records else { return }
            self.delegate?.onFetchMarkMessages(records,loadMore)
        }.failed { error in
            SVProgressHUD.showError(withStatus: "获取标注消息记录失败 code:\(error.code)")
        }
    }
    
    func getConversation(communityId: String, channelId: String) -> RCConversation? {
        return channelClient.getConversation(.ConversationType_ULTRAGROUP, targetId: communityId, channelId: channelId)
    }
}

extension RCSCConversationMessageManager {
    //第一次加载会话
    static func fetchConversationInitializedHistoryMessage(communityId: String, channelId: String, conversation: RCConversation?) {
        Self.manager.historyMessageHandler.fetchConversationInitializedHistoryMessage(communityId: communityId, channelId: channelId, conversation: conversation)
    }
    
    //根据messageUid获取消息
    static func fetchMessageByMessageUid(messageUid: String) -> RCMessage? {
        return Self.manager.historyMessageHandler.fetchMessageByMessageUid(messageUid: messageUid)
    }
    //获取标注消息列表
    static func fetchConversationMarkHistoryMessage(communityId: String, channelId: String, pageNum: Int, pageSize: Int, loadMore: Bool = false) {
        Self.manager.historyMessageHandler.fetchMarkMessageList(channelUid: channelId, pageNum: pageNum, pageSize: pageSize, loadMore: loadMore)
    }
    
    //第一次加载后分页拉去历史消息
    static func fetchHistoryMessage(communityId:String, channelId: String, sendTime: Int64, strategy: RCSCFetchMessageStrategy, fix: Bool = true) {
        Self.manager.historyMessageHandler.fetchHistoryMessage(communityId: communityId, channelId: channelId, sendTime: sendTime, strategy: strategy, fix: fix)
    }
    
    //根据 message Uid 获取 message
    static func getMessageByUid(messageUid: String) -> RCMessage? {
        return Self.manager.historyMessageHandler.fetchMessageByMessageUid(messageUid: messageUid)
    }
    
    //获取会话对象
    static func getConversation(communityId: String, channelId: String) -> RCConversation? {
        return Self.manager.historyMessageHandler.getConversation(communityId: communityId, channelId: channelId)
    }
}
