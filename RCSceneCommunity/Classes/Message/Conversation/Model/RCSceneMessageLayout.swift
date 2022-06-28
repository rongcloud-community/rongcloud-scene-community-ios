//
//  RCSceneMessageLayout.swift
//  RCSceneCommunity
//
//  Created by shaoshuai on 2022/3/30.
//

import UIKit

class RCSceneMessageLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        estimatedItemSize = CGSize(width: kScreenWidth, height: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let objects = super.layoutAttributesForElements(in: rect)
        objects?
            .filter { $0.representedElementCategory == .cell }
            .forEach { item in
                let newItem = layoutAttributesForItem(at: item.indexPath)
                item.frame = newItem?.frame ?? item.frame
            }
        return objects
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { fatalError() }
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        let contentWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
        let width = contentWidth - sectionInset.left - sectionInset.right
        layoutAttributes.frame.origin.x = sectionInset.left
        layoutAttributes.frame.size.width = width
        return layoutAttributes
    }
}
