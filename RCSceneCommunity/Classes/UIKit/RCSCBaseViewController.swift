//
//  RCSCBaseViewController.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/20.
//

import UIKit

open class RCSCBaseViewController:UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.defaultAppearance()
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.shadowImage = UIImage.createImageWithColor(color: Asset.Colors.grayE5E8EF.color)
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

//extension RCSCBaseViewController: UINavigationControllerDelegate {
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
