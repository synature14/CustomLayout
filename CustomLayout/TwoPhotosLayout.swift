//
//  TwoPhotosLayout.swift
//  CustomLayout
//
//  Created by sutie on 2018. 7. 21..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit

class TwoPhotosLayout: UICollectionViewLayout {
    
    var delegate: PhotoLayoutDelegate!
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
        guard let _ = collectionView else {
            return .zero
        }
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    lazy var highlightView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "0x4490FF")
        return v
    }()
    
    override public func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView, let delegate = delegate else {
            return
        }
        
        cache.removeAll()
        
        // 두번째 사진이 추가될때
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // 3
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 첫번째 사진의 높이만큼 두번쨰 사진도 높이 조절
            if indexPath.item == 0 {
                photoHeight = collectionView.bounds.height
//                photoHeight = delegate.size(at: indexPath).height
            }
            
            // 4
            let height = cellSpacing * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellSpacing, dy: cellSpacing)
            
            // 5
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
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
