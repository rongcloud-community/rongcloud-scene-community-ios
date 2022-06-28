//
//  RCSCTableCellProtocol.swift
//  Kingfisher
//
//  Created by shaoshuai on 2022/3/9.
//

import UIKit

protocol RCSCCellProtocol where Self: UICollectionViewCell {
    func updateUI(_ message: RCMessage) -> RCSCCellProtocol
}
