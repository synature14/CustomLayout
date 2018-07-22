//
//  RDImageCollage.swift
//  article
//
//  Created by 안덕환 on 2018. 2. 12..
//  Copyright © 2018년 Naver. All rights reserved.
//

import Foundation
import Photos
//import RxSwift
protocol RDPhotoLayoutDelegate {
    func size(at: IndexPath) -> CGSize
}

public class RDPhotoCollageLayout: UICollectionViewLayout {
    
    var cachedAttributesList: [UICollectionViewLayoutAttributes] = []
    var cachedBlankAreaList: [CGRect] = []
    
    var sectionInsets: UIEdgeInsets = .zero
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width - (sectionInsets.left + sectionInsets.right)
    }
    
    override public var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: contentHeight)
    }
    
    lazy var highlightView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "0x4490FF")
        return v
    }()
    
//    weak var delegate: RDPhotoLayoutDelegate?
    var delegate: RDPhotoLayoutDelegate?
    var cellSpacing: CGFloat = 5
    var lineSpacing: CGFloat = 5
    var isHighlighted = false
    var blankAreaWidth: CGFloat = 70
    
    private func attributesIndexPaths(at row: Int) -> [Int]? {
        guard row >= 0, row <= cachedAttributesList.count / 2 else { return nil }
        var indexPaths: [Int] = []
        let leftIndex = row * 2
        indexPaths.append(leftIndex)
        
        let rightIndex = leftIndex + 1
        if rightIndex < cachedAttributesList.count { indexPaths.append(rightIndex) }
        return indexPaths
    }
    
    private func calculateOffset() -> CGFloat {
        guard let collectionView = collectionView, let delegate = delegate else { return 0 }
        var total: CGFloat = 0
        var topSpacing: CGFloat = sectionInsets.top
        print("collectionView.numberOfItems(inSection: 0) = \(collectionView.numberOfItems(inSection: 0))")
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoSize = delegate.size(at: indexPath)
            if item % 2 == 0 {      // 다음줄
                total = topSpacing + lineSpacing + photoSize.height
            } else {
                topSpacing += photoSize.height
            }
        }
        
        return collectionView.frame.size.height > total ? (collectionView.frame.size.height - total) / 2 : 0.0
    }
    
    override public func prepare() {
        guard let collectionView = collectionView, let delegate = delegate, !isHighlighted else { return }
        
        super.prepare()
        resetLayout()
        
        var leftSpacing: CGFloat = sectionInsets.left
        let centerYOffset: CGFloat = calculateOffset()
        var topSpacing: CGFloat = sectionInsets.top + centerYOffset
        
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            switch attributes.representedElementCategory {
            case .cell:
                let photoSize = delegate.size(at: indexPath)
                let cellFrame: CGRect = CGRect(origin: CGPoint(x: leftSpacing, y: topSpacing), size: photoSize)
                attributes.frame = cellFrame
                cachedAttributesList.append(attributes)
                
                if item % 2 == 0 {
                    // left
                    let leftBlank = CGRect(
                        origin: CGPoint(x: leftSpacing - ((cellSpacing + blankAreaWidth) / 2), y: topSpacing),
                        size: CGSize(width: blankAreaWidth, height: photoSize.height))
                    cachedBlankAreaList.append(leftBlank)
                    
                    leftSpacing += photoSize.width + cellSpacing
                    contentHeight = topSpacing + lineSpacing + photoSize.height
                    
                    // center
                    let centerBlank = CGRect(
                        origin: CGPoint(x: leftSpacing - cellSpacing + (cellSpacing / 2) - (blankAreaWidth / 2), y: topSpacing),
                        size: CGSize(width: blankAreaWidth, height: photoSize.height))
                    cachedBlankAreaList.append(centerBlank)
                } else {
                    // right
                    let rightBlank = CGRect(
                        origin: CGPoint(x: leftSpacing + (cellSpacing / 2) + photoSize.width - (blankAreaWidth / 2), y: topSpacing),
                        size: CGSize(width: blankAreaWidth, height: photoSize.height))
                    cachedBlankAreaList.append(rightBlank)
                    
                    topSpacing += photoSize.height + lineSpacing
                    leftSpacing = sectionInsets.left
                }
            default:
                break
            }
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var intersectedAttributesList: [UICollectionViewLayoutAttributes] = []
        for attributes in cachedAttributesList {
            if rect.intersects(attributes.frame) {
                intersectedAttributesList.append(attributes)
            }
        }
        return intersectedAttributesList
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item >= 0, indexPath.item < cachedAttributesList.count else { return nil }
        return cachedAttributesList[indexPath.item]
    }
    
    private func resetLayout() {
        cachedAttributesList.removeAll()
        cachedBlankAreaList.removeAll()
        contentHeight = 0
        highlightView.removeFromSuperview()
    }
    
    private func isLastRow(_ row: Int) -> Bool {
        if row == cachedAttributesList.count / 2 {
            return true
        } else {
            return false
        }
    }
    
    func nearIndexPath(to blankIndex: Int) -> IndexPath? {
        guard blankIndex >= 0, blankIndex < cachedBlankAreaList.count else { return nil }
        
        let row = blankIndex / 3
        let colum = blankIndex % 3
        
        let cellIndex = row * 2 + colum
        if cellIndex >= 0, cellIndex <= cachedAttributesList.count {
            return IndexPath(item: cellIndex, section: 0)
        } else {
            return nil
        }
    }
    
    func overlapsBlank(with point: CGPoint) -> Int? {
        return cachedBlankAreaList.index { $0.contains(point) }
    }
    
    func highlightBlank(at index: Int) {
        if isHighlighted { return }
        
        let row = index / 3
        let colum = index % 3
        
        // 마지막 라인에, 사진이 하나인 경우
        if isLastRow(row), cachedAttributesList.count % 2 == 1 {
            highlightBlankInOnePhoto(row: row, colum: colum)
        } else {
            highlightBlankInTwoPhoto(row: row, colum: colum)
        }
        isHighlighted = true
        invalidateLayout()
    }
    
    func turnOffHighlight() {
        if !isHighlighted { return }
        
        highlightView.removeFromSuperview()
        isHighlighted = false
        invalidateLayout()
    }
    
    private func highlightBlankInTwoPhoto(row: Int, colum: Int) {
        guard let indexPaths = attributesIndexPaths(at: row), indexPaths.count == 2 else { return }
        
        let leftAttributes = cachedAttributesList[indexPaths[0]]
        let rightAttributes = cachedAttributesList[indexPaths[1]]
        switch colum {
        case 0:
            leftAttributes.frame.origin.x += 5
            rightAttributes.frame.origin.x += 5
            rightAttributes.frame.size.width -= 5
            displayHighlight(at: calculateOrigin(leftAttributes.frame.origin, xOffset: -9), size: CGSize(width: 3, height: leftAttributes.frame.height))
        case 1:
            leftAttributes.frame.size.width -= 5
            rightAttributes.frame.origin.x += 5
            rightAttributes.frame.size.width -= 5
            displayHighlight(at: calculateOrigin(rightAttributes.frame.origin, xOffset: -9), size: CGSize(width: 3, height: rightAttributes.frame.height))
        case 2:
            leftAttributes.frame.size.width -= 5
            rightAttributes.frame.origin.x -= 5
            let origin = CGPoint(x: rightAttributes.frame.maxX, y: rightAttributes.frame.minY)
            displayHighlight(at: calculateOrigin(origin, xOffset: 6), size: CGSize(width: 3, height: rightAttributes.frame.height))
        default:
            break
        }
        cachedAttributesList[indexPaths[0]] = leftAttributes
        cachedAttributesList[indexPaths[1]] = rightAttributes
    }
    
    private func highlightBlankInOnePhoto(row: Int, colum: Int) {
        guard let indexPaths = attributesIndexPaths(at: row), let index = indexPaths.first else { return }
        
        let attributes = cachedAttributesList[index]
        switch colum {
        case 0:
            attributes.frame.origin.x += 5
            attributes.frame.size.width -= 5
            displayHighlight(at: calculateOrigin(attributes.frame.origin, xOffset: -9), size: CGSize(width: 3, height: attributes.frame.height))
        case 1:
            attributes.frame.size.width -= 5
            let frame = cachedAttributesList[index].frame
            let origin = CGPoint(x: frame.maxX, y: frame.minY)
            displayHighlight(at: calculateOrigin(origin, xOffset: 6), size: CGSize(width: 3, height: frame.height))
        default:
            break
        }
        cachedAttributesList[index] = attributes
    }
    
    private func calculateOrigin(_ origin: CGPoint, xOffset: CGFloat) -> CGPoint {
        return CGPoint(x: origin.x + xOffset, y: origin.y)
    }
    
    private func displayHighlight(at origin: CGPoint, size: CGSize) {
        highlightView.frame.origin = origin
        highlightView.frame.size = size
        collectionView?.addSubview(highlightView)
    }
}

//
//class PhotoCollageProvider: PhotoProvider {
//
//    private var adjustedPhotosSize: [CGSize]?
//    private var photoRepository: RDPhotoRepository?
//
//    init(photoRepository: RDPhotoRepository) {
//        self.photoRepository = photoRepository
//    }
//
//    func adjustPhotosSize(within width: CGFloat, spacing: CGFloat = 0) {
//        guard let photoRepository = photoRepository else { return }
//        var photosSize: [CGSize] = []
//
//        for (index, _) in photoRepository.enumerated() {
//            if index % 2 == 0 {
//                if hasPhoto(at: index + 1) {
//                    guard let leftImage = image(at: index), let rightImage = image(at: index + 1) else { return }
//
//                    let leftImageRatio = aspectRatio(at: index)
//                    let rightImageRatio = aspectRatio(at: index + 1)
//                    let sumAspectRatio = leftImageRatio + rightImageRatio
//
//                    let adjustedWidth = width - spacing
//
//                    let leftWidth = adjustedWidth * leftImageRatio / sumAspectRatio
//                    let rightWidth = adjustedWidth * rightImageRatio / sumAspectRatio
//
//                    let leftAdjustedRatio = leftWidth / leftImage.size.width
//                    let rightAdjustedRatio = rightWidth / rightImage.size.width
//
//                    let leftHeight = leftImage.size.height * leftAdjustedRatio
//                    let rightHeight = rightImage.size.height * rightAdjustedRatio
//
//                    let adjustedHeight = max(leftHeight, rightHeight)
//
//                    photosSize.append(CGSize(width: leftWidth, height: adjustedHeight))
//                    photosSize.append(CGSize(width: rightWidth, height: adjustedHeight))
//                } else {
//                    let height = calculateHeight(at: index, within: width)
//                    photosSize.append(CGSize(width: width, height: height))
//                }
//            }
//        }
//        adjustedPhotosSize = photosSize
//    }
//
//    func insert(from: Int, to: Int) -> Bool {
//        return photoRepository?.insert(from, to) ?? false
//    }
//
//    func image(at index: Int) -> UIImage? {
//        guard let photoRepository = photoRepository, index >= 0, index < photoRepository.numberOfPhotos else {
//            return nil
//        }
//        return photoRepository.photo(at: index)
//    }
//
//    func hasPhoto(at index: Int) -> Bool {
//        guard let photoRepository = photoRepository else { return false }
//        if index >= 0, index <  photoRepository.numberOfPhotos { return true }
//        else { return false }
//    }
//
//    private func aspectRatio(at index: Int) -> CGFloat {
//        guard let photoRepository = photoRepository, let photo = photoRepository.photo(at: index),
//            index >= 0, index < photoRepository.numberOfPhotos else { return 0 }
//
//        return photo.size.width / photo.size.height
//    }
//
//    private func calculateHeight(at index: Int, within width: CGFloat) -> CGFloat {
//        guard let photoRepository = photoRepository, let photo = photoRepository.photo(at: index),
//            index >= 0, index < photoRepository.numberOfPhotos else {
//                return 0
//        }
//
//        return (width / photo.size.width) * photo.size.height
//    }
//
//    func getAdjustedPhotoSize(at index: Int) -> CGSize {
//        guard let photoRepository = photoRepository, index >= 0, index < photoRepository.numberOfPhotos,
//            let adjustedPhotoSizeList = adjustedPhotosSize else {
//                return .zero
//        }
//        return adjustedPhotoSizeList[index]
//    }
//}
