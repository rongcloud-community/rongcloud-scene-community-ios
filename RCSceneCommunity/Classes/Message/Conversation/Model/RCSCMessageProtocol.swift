//
//  RCSCMessageProtocol.swift
//  Kingfisher
//
//  Created by shaoshuai on 2022/3/9.
//

import UIKit

protocol RCSCMessageProtocol where Self: RCMessageContent {
    func view() -> RCSCCellProtocol.Type
    func identifier() -> String
    func quoteText() -> String
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>?
}

extension RCTextMessage: RCSCMessageProtocol {
    func view() -> RCSCCellProtocol.Type {
        return RCSCMessageTextCell.self
    }
    
    func identifier() -> String {
        return "RCSC:Txt:Msg:Cell"
    }
    
    func quoteText() -> String {
        return content
    }
    
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>? {
        return owner ? [.edit, .quote, .copy, .delete] : [.quote, .copy]
    }
}

extension RCImageMessage: RCSCMessageProtocol {
    func view() -> RCSCCellProtocol.Type {
        return RCSCMessageImageCell.self
    }
    
    func identifier() -> String {
        return "RCSC:Image:Msg:Cell"
    }
    
    func quoteText() -> String {
        return "[图片]"
    }
    
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>? {
        return owner ? [.quote, .delete] : [.quote]
    }
}

extension RCSightMessage: RCSCMessageProtocol {
    func view() -> RCSCCellProtocol.Type {
        return RCSCMessageVideoCell.self
    }
    
    func identifier() -> String {
        return "RCSC:Video:Msg:Cell"
    }
    
    func quoteText() -> String {
        return "[视频]"
    }
    
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>? {
        return owner ? [.quote, .delete] : [.quote]
    }
}


extension RCRecallNotificationMessage: RCSCMessageProtocol {
    func view() -> RCSCCellProtocol.Type {
        return RCSCMessageRecallCell.self
    }
    
    func identifier() -> String {
        return "RCSC:Recall:Msg:Cell"
    }
    
    func quoteText() -> String {
        return "该消息已撤回"
    }
    
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>? {
        return []
    }
}

extension RCReferenceMessage: RCSCMessageProtocol {
    func view() -> RCSCCellProtocol.Type {
        if referMsgUid != nil, let message = RCSCConversationMessageManager.getMessageByUid(messageUid: referMsgUid),
           message.content is RCRecallNotificationMessage {
            return RCSCMessageQuoteRecallCell.self
        }
        if referMsg is RCTextMessage || referMsg is RCReferenceMessage {
            return RCSCMessageQuoteTextCell.self
        } else if referMsg is RCImageMessage {
            return RCSCMessageQuoteImageCell.self
        } else if referMsg is RCSightMessage {
            return RCSCMessageQuoteVideoCell.self
        } else {
            fatalError("当前消息不支持引用")
        }
    }
    
    func identifier() -> String {
        
        if referMsgUid != nil, let message = RCSCConversationMessageManager.getMessageByUid(messageUid: referMsgUid),
           message.content is RCRecallNotificationMessage {
            return "RCSC:Reference:Recall:Msg:Cell"
        }
        
        if referMsg is RCTextMessage || referMsg is RCReferenceMessage {
            return "RCSC:Reference:Text:Msg:Cell"
        } else if referMsg is RCImageMessage {
            return "RCSC:Reference:Image:Msg:Cell"
        } else if referMsg is RCSightMessage {
            return "RCSC:Reference:Video:Msg:Cell"
        } else {
            fatalError("当前消息不支持引用")
        }
    }
    
    func quoteText() -> String {
        return content
    }
    
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>? {
        return owner ? [.edit, .quote, .copy, .delete] : [.quote, .copy]
    }
}

extension RCSCChannelNoticeMessage: RCSCMessageProtocol {
    func view() -> RCSCCellProtocol.Type {
        return RCSCMessageChannelNoticeCell.self
    }
    
    func identifier() -> String {
        return "RCSC:ChannelNotice:Msg:Cell"
    }
    
    func quoteText() -> String {
        return "系统消息不支持该操作"
    }
    func supportOperations(owner: Bool) -> Array<RCSCMessageOperation>? {
        return []
    }
}
