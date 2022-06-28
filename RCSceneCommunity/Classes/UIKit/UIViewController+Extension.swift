//
//  UIViewController+Extension.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/15.
//

import Foundation

extension UIViewController {
    func enableClickingDismiss(_ index: Int = 0) {
        let tapView = UIView(frame: view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(tapView, at: index)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickingDismissTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    func enableClickingDismiss(above view: UIView) {
        let tapView = UIView(frame: self.view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(tapView, aboveSubview: view)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickingDismissTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    func enableClickingDismiss(below view: UIView) {
        let tapView = UIView(frame: self.view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(tapView, belowSubview: view)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickingDismissTap))
        tapView.addGestureRecognizer(gesture)
    }
    
    @objc private func onClickingDismissTap() {
        dismiss(animated: true)
    }
    
    func showAlert(with title: String, confirmCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确认", style: .destructive) { _ in
            confirmCompletion()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { _ in
            debugPrint("取消")
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

//需要隐藏 navigation bar 的页面在 view will appear 中设置 self.navigationController.delegate = self
//extension UIViewController: UINavigationControllerDelegate {
//    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if (viewController === self) {
//            navigationController.setNavigationBarHidden(true, animated: false)
//        } else {
//            navigationController.setNavigationBarHidden(false, animated: false)
//            if let _ = navigationController.delegate {
//                navigationController.delegate = nil
//            }
//        }
//    }
//}
