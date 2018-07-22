//
//  OnePhotoLayout.swift
//  CustomLayout
//
//  Created by sutie on 2018. 7. 21..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit

class OnePhotoLayout: UICollectionViewLayout {
    
    var delegate: RDPhotoLayoutDelegate?
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    let indexPath = IndexPath(item: 0, section: 0)
    
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        contentHeight = collectionView.frame.size.height
        let frame = CGRect(x: 0, y: 0,
                           width: contentWidth, height: contentHeight)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = frame
        cache.append(attributes)
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        // 사진이 두개 이상이면
        if indexPath.item > 0 {
            return nil
        }
        
        return cache[indexPath.item]
    }
}
