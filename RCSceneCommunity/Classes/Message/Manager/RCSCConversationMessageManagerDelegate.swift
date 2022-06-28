//
//  RCSCMessageManagerDelegate.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/12.
//

import Foundation
import SwiftUI  //???: swiftUI?

enum RCSCFetchMessageStrategy: Int {
    case before
    case after
}

protocol RCSCConversationMessageManagerDelegate: NSObjectProtocol {
    func onUltraGroupReadTimeReceived(_ targetId: String!, channelId: String!, readTime: Int64)
    func onUltraGroupTypingStatusChanged(_ infoArr: [RCUltraGroupTypingStatusInfo]!)
    func onUltraGroupMessageModified(_ messages: [RCMessage]!)
    func onUltraGroupMessageRecalled(_ messages: [RCMessage]!)
    func onUltraGroupMessageExpansionUpdated(_ messages: [RCMessage]!)
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!)
    func onReceivedSystem(_ message: RCMessage!, left nLeft: Int32, object: Any!)
    func onMessageSend(_ message: RCMessage?)
    func onFetchHistoryMessagesSuccess(messages:Array<RCMessage>, strategy: RCSCFetchMessageStrategy)
    func onMessageModified(_ messages: [RCMessage]!)
    func onMessageRecall(_ messages: [RCMessage]!)
    func onFetchMarkMessages(_ messages: [RCSCMarkMessage]!, _ loadMore: Bool)
    func syncCommunityReadStatus(_ success: Bool, _ errorCode: RCErrorCode?)
}

extension RCSCConversationMessageManagerDelegate {
    func onUltraGroupReadTimeReceived(_ targetId: String!, channelId: String!, readTime: Int64) {}
    func onUltraGroupTypingStatusChanged(_ infoArr: [RCUltraGroupTypingStatusInfo]!) {}
    func onUltraGroupMessageModified(_ messages: [RCMessage]!) {}
    func onUltraGroupMessageRecalled(_ messages: [RCMessage]!) {}
    func onUltraGroupMessageExpansionUpdated(_ messages: [RCMessage]!) {}
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {}
    func onReceivedSystem(_ message: RCMessage!, left nLeft: Int32, object: Any!){}
    func onMessageSend(_ message: RCMessage?) {}
    func onFetchHistoryMessagesSuccess(messages:Array<RCMessage>, strategy: RCSCFetchMessageStrategy) {}
    func onMessageModified(_ messages: [RCMessage]!) {}
    func onMessageRecall(_ messages: [RCMessage]!) {}
    func onFetchMarkMessages(_ messages: [RCSCMarkMessage]!, _ loadMore: Bool) {}
    func syncCommunityReadStatus(_ success: Bool, _ errorCode: RCErrorCode?) {}
}
