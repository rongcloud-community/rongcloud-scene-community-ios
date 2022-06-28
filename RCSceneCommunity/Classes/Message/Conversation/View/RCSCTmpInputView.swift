//
//  RCSCTmpInputView.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/17.
//

import ISEmojiView
import GrowingTextView
import SVProgressHUD
import Foundation

protocol RCSCTmpInputViewProtocol: AnyObject {
    func inputViewDidClickSend(_ text: String, _ atUsers: Array<RCSCCommunityUser>?)
    func inputViewDidSelectedMediaType(_ type: RCSCMessageType)
    func quoteMessageDidClickSend(_ text: String, _ message: RCMessage, _ opt: RCSCMessageOperation, _ atUsers: Array<RCSCCommunityUser>?)
    func jumpUserListViewController()
    func inputViewTyping()
}

class RCSCTmpInputView: UIView {
    
    weak var delegate: RCSCTmpInputViewProtocol? {
        willSet {
            additionView.delegate = newValue
        }
    }
    
    private lazy var lineView = UIView()
    private lazy var textView = GrowingTextView()
    private lazy var textContainerView = UIView()
    private lazy var emojiButton = UIButton()
    private lazy var pluginButton = UIButton()
    
    private lazy var emojiView: EmojiView = {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        return emojiView
    }()
    
    private lazy var additionView: RCSCConversationAdditionView = {
        let frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 160)
        let additionView = RCSCConversationAdditionView(frame: frame)
        additionView.delegate = delegate
        return additionView
    }()

    private lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        sendButton.setTitle("发送", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = Asset.Colors.blue0099FF.color
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 10
        sendButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        sendButton.isHidden = true
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        return sendButton
    }()
    
    var operation: (opt: RCSCMessageOperation, msg: RCMessage)? {
        willSet {
            lineView.isHidden = true
            textView.inputView = nil
            layoutIfNeeded()
            UIView.animate(withDuration: 0.35) { [self] in
                self.textView.reloadInputViews()
            }
            if !textView.isFirstResponder {
                textView.becomeFirstResponder()
            }
        }
    }
    
    var atUsers = Array<RCSCCommunityUser>() {
        didSet {
            if let user = atUsers.last {
                if let range = currentAtRange {
                    handleAtUserText(user: user, range: NSRange(location: range.location, length: 1))
                }
            }
        }
    }
    
    override var isHidden: Bool {
        didSet {
            super.isHidden = isHidden
            if isHidden {
                textView.resignFirstResponder()
            }
        }
    }
    
    var currentAtRange: NSRange?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textContainerView)
        textContainerView.addSubview(textView)
        addSubview(emojiButton)
        addSubview(pluginButton)
        addSubview(sendButton)
        addSubview(lineView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHidden), name: RCSCTmpInputView.keyboardDidHideNotification, object: nil)
        
        lineView.backgroundColor = UIColor(red: 229 / 255.0, green: 232 / 255.0, blue: 239 / 255.0, alpha: 1)
        lineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        textContainerView.backgroundColor = UIColor(white: 243 / 255.0, alpha: 1)
        textContainerView.layer.cornerRadius = 20
        textContainerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview().offset(17)
            make.right.equalTo(emojiButton.snp.left).offset(-10)
        }
        
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(5)
            make.height.greaterThanOrEqualTo(30)
        }
        textView.delegate = self
        textView.minHeight = 30
        textView.maxHeight = 120
        textView.maxLength = 1000
        textView.trimWhiteSpaceWhenEndEditing = false
        textView.font = .systemFont(ofSize: 14)
        textView.placeholder = "聊点什么..."
        textView.placeholderColor = .black.alpha(0.2)
        textView.backgroundColor = UIColor(white: 243 / 255.0, alpha: 1)
        textView.returnKeyType = .send
        
        emojiButton.setImage(Asset.Images.emoji.image, for: .normal)
        emojiButton.addTarget(self, action: #selector(emojiButtonClicked), for: .touchUpInside)
        emojiButton.snp.makeConstraints { make in
            make.bottom.equalTo(textContainerView)
            make.width.height.equalTo(40)
            make.right.equalTo(pluginButton.snp.left).offset(-10)
        }
        
        pluginButton.setImage(Asset.Images.plugin.image, for: .normal)
        pluginButton.addTarget(self, action: #selector(pluginButtonClicked), for: .touchUpInside)
        pluginButton.snp.makeConstraints { make in
            make.centerY.equalTo(emojiButton)
            make.width.height.equalTo(40)
            make.right.equalToSuperview().offset(-14)
        }
        
        sendButton.snp.makeConstraints { make in
            make.edges.equalTo(pluginButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func emojiButtonClicked() {
        if textView.inputView is EmojiView {
            textView.inputView = nil
            sendButton.isHidden = true
        } else {
            textView.inputView = emojiView
            sendButton.isHidden = false
        }
        
        layoutIfNeeded()
        UIView.animate(withDuration: 0.35) {
            self.textView.reloadInputViews()
        }
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
        emojiButton.isSelected.toggle()
    }
    
    @objc private func pluginButtonClicked() {
        if textView.inputView is RCSCConversationAdditionView {
            textView.inputView = nil
        } else {
            textView.inputView = additionView
        }
        layoutIfNeeded()
        UIView.animate(withDuration: 0.35) {
            self.textView.reloadInputViews()
        }
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
        emojiButton.isSelected.toggle()
    }
    
    @objc private func sendButtonClicked() {
        guard let text = textView.text, text.count > 0 else {
            return SVProgressHUD.showError(withStatus: "不能发送空白消息")
        }
        sendTextMessage()
        sendButton.isHidden = true
    }
    
    @objc private func keyboardDidHidden() {
        textView.inputView = nil
        sendButton.isHidden = true
    }
    
    override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
        lineView.isHidden = false
        return super.resignFirstResponder()
    }
    
    func handleAtUserText(user: RCSCCommunityUser, range: NSRange) {
        if let newRange = textView.text.toRange(range) {
            textView.text.replaceSubrange(newRange, with: atString(user: user))
            //textViewDidChange(textView)
        }
    }
    
    func atString(user: RCSCCommunityUser) -> String {
        return "@\(user.name) "
    }
    
    func atNickNameRanges(users: Array<RCSCCommunityUser>) -> Array<NSRange>? {
        guard let text = textView.text else { return nil }
        var ranges = Array<NSRange>()
        for user in users {
            ranges = ranges + text.getNSRanges(string: atString(user: user))
        }
        
        if ranges.count == 1 { return ranges }
        
        var result = Array<NSRange>()
        
        for range in ranges {
            var find = false
            for value in result {
                if value.location == range.location && value.length == range.length {
                    find = true
                    break
                }
            }
            if !find {
                result.append(range)
            } else {
                continue
            }
        }
        return result
    }
    
    private func sendTextMessage() {
        /// textView.text 该情况下一定有内容
        if let operation = operation,
           let content = textView.text,
           content.count > 0 {
            delegate?.quoteMessageDidClickSend(content, operation.msg, operation.opt, atUsers)
            debugPrint(content)
        } else if let content = textView.text,
                  content.count > 0 {
            delegate?.inputViewDidClickSend(content, atUsers)
            debugPrint(content)
        } else {
            SVProgressHUD.showError(withStatus: "不能发送空白消息")
        }
        
        textView.text = ""
        operation = nil
        lineView.isHidden = false
        atUsers.removeAll()
    }
}

public extension Array where Element: Equatable {
    func removeDuplicateNSRange() -> Array {
       return self.enumerated().filter { (index,value) -> Bool in
            return self.firstIndex(of: value) == index
        }.map { (_, value) in
            value
        }
    }
}
extension RCSCTmpInputView: GrowingTextViewDelegate {
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    /*
    func textViewDidChange(_ textView: UITextView) {
        
        guard let _ = textView.text else { return }
        let selectRange = textView.selectedRange
        print(selectRange)
        if let textRange = selectRange.toTextRange(textInput: textView), let text = textView.text(in: textRange), text.count < 1 {
            let textView = textView
            let range = textView.selectedRange
            let attr = NSMutableAttributedString(string: textView.text)
            attr.addAttributes([.foregroundColor: UIColor.black], range: NSRange(location: 0, length: text.count))
            guard let ranges = atNickNameRanges(users: atUsers) else { return }
            for range in ranges {
                attr.addAttributes([.foregroundColor: Asset.Colors.blue0099FF.color], range: NSRange(location: range.location, length: range.length - 1))
            }
            textView.selectedRange = range
            textView.attributedText = attr
        }
         
    }
    */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.inputViewTyping()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        delegate?.inputViewTyping()
        if text == "\n" {
            sendTextMessage()
            return false
        }
        else if text == "@" {
            currentAtRange = range
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.jumpUserListViewController()
            }
        } else if text == "" {
            let selectRange = textView.selectedRange
            guard selectRange.length == 0,
                  let text = textView.text,
                  let ranges = atNickNameRanges(users: atUsers)
            else { return true}
            let mutableString = NSMutableString(string: text)
            var find = false
            var index = range.location
            for (idx, value) in ranges.enumerated() {
                let newRange = NSRange(location: value.location, length:value.length)
                if NSLocationInRange(range.location, newRange) {
                    find = true
                    index = value.location
                    mutableString.replaceCharacters(in: value, with: "")
                    atUsers.remove(at: idx)
                    break
                }
            }
            
            if find {
                textView.text = mutableString as String
                textView.selectedRange = NSRange(location: index, length: 0)
                //textViewDidChange(textView)
                return false
            }
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let ranges = atNickNameRanges(users: atUsers) else { return }
        let range = textView.selectedRange
        if range.length > 0 { return }
        for value in ranges {
            let newRange = NSRange(location: value.location + 1, length: value.length - 1)
            if NSLocationInRange(range.location, newRange) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    textView.selectedRange = NSRange(location: value.location + value.length, length: 0)
                }
                break
            }
        }
    }
}

extension RCSCTmpInputView: EmojiViewDelegate {
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textView.insertText(emoji)
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textView.deleteBackward()
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        textView.resignFirstResponder()
    }
}
