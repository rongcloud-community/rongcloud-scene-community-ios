//
//  RCSCKeyboardObserver.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/15.
//


class RCSCBox<T: AnyObject> {
  weak var value : T?
  init (value: T?) {
    self.value = value
  }
}

class RCSCKeyboardObserver {
    
    //public
    static let shared = RCSCKeyboardObserver()
    
    static func registerObserver(_ ob: (inputView: RCSCBox<UIView>, contentView: RCSCBox<UIView>)) {
        guard let inputView = ob.inputView.value,
              let _ = ob.contentView.value
              else { return }
        shared.data[inputView] = ob
    }
    
    static func unRegisterObserver(inputView: UIView) {
        shared.data.removeValue(forKey: inputView)
    }
    
    //private
    private var data: Dictionary<UIView, (inputView: RCSCBox<UIView>, contentView: RCSCBox<UIView>)> = Dictionary()
    
    private var originY: CGFloat = 0
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide(notification:)),name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        for val in data.values {
            guard let inputView = val.inputView.value,
                  let contentView = val.contentView.value else {
                      continue
                  }
            originY = contentView.frame.origin.y
            
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let rect = inputView.convert(inputView.bounds, to: contentView)
            let y = contentView.bounds.height - rect.origin.y - rect.size.height - keyboardHeight
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    if y < 0 {
                        contentView.frame.origin.y = y
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        for val in data.values {
            guard let _ = val.inputView.value,
                  let contentView = val.contentView.value else {
                      continue
                  }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    contentView.frame.origin.y = self.originY
                }
            }
        }
        
        let result = data.filter { (key: UIView, value: (inputView: RCSCBox<UIView>, contentView: RCSCBox<UIView>)) -> Bool in
            return value.inputView.value != nil && value.contentView.value != nil
        }
        data = result
    }
}
