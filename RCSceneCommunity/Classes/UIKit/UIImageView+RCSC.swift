//
//  Kingfisher+RCSC.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/4/13.
//

import Foundation

extension UIImageView {
    func setImage(with imageUrl: String, placeholder: UIImage? = nil) {
        if !imageUrl.isEmpty {
            self.kf.setImage(with: URL(string: imageUrl.handeAvatarFullPath()), placeholder: placeholder, options: nil, completionHandler: nil)
        } else if let placeholder = placeholder {
            self.image = placeholder
        }
    }
}
