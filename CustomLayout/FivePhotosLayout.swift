//
//  FivePhotosLayout.swift
//  CustomLayout
//
//  Created by sutie on 2018. 7. 22..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit

class FivePhotosLayout: UICollectionViewLayout {
    var delegate: RDPhotoLayoutDelegate!
    var cellSpacing: CGFloat = 2.5
    // 3
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    var numberOfColumns = 2
    var photoHeight = CGFloat(0)
    
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    
    override public var collectionViewContentSize: CGSize {
        guard let _ = collectionView else { return .zero }
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    lazy var highlightView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "0x4490FF")
        return v
    }()
    
    override public func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView, collectionView.numberOfItems(inSection: 0) == 5,
            let _ = delegate else {
                return
        }
        
        cache.removeAll()
        contentHeight = collectionView.bounds.height
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        let numberOfFirstRowPhoto = 2
        let firstRowPhotoHeight = contentHeight * (2 / 3)
        let firstRowPhotoWidth = contentWidth / CGFloat(numberOfFirstRowPhoto)
        
        for item in 0 ..< numberOfFirstRowPhoto {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame.size.height = firstRowPhotoHeight
            attributes.frame.size.width = firstRowPhotoWidth
            attributes.frame.origin = CGPoint(x: xOffset, y: yOffset)
            xOffset += firstRowPhotoWidth + cellSpacing
            cache.append(attributes)
        }
        
        yOffset = firstRowPhotoHeight
        xOffset = 0
        
        let numberOfSecondRowPhoto = 3
        let secondRowPhotoHeight = contentHeight * (1 / 3)
        let secondRowPhotoWidth = contentWidth / CGFloat(numberOfSecondRowPhoto)
        
        for item in 2 ..< 5 {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame.size.height = secondRowPhotoHeight
            attributes.frame.size.width = secondRowPhotoWidth
            attributes.frame.origin = CGPoint(x: xOffset, y: yOffset)
            xOffset += secondRowPhotoWidth + cellSpacing
            cache.append(attributes)
        }
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
        guard indexPath.item >= 0, indexPath.item < cache.count else {
            return nil
        }
        return cache[indexPath.item]
    }
}
