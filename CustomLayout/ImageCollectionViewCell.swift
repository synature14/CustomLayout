//
//  ImageCollectionViewCell.swift
//  CustomLayout
//
//  Created by sutie on 2018. 7. 21..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eachImageView: UIImageView!
}

class SmallImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var model: UIImage? {
        didSet {
            imageView.image = model
        }
    }
}

class MultiImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bigImageView: UIImageView!
    
    private var bigItem: UIImage?
    private var items: [UIImage] = []
    
    func setModels(bigItem: UIImage?, items: [UIImage]) {
        self.bigItem = bigItem
        self.items = items
        updateUI()
    }
    
    private func updateUI() {
        bigImageView.image = bigItem
        collectionView.reloadData()
    }
}

extension MultiImageCollectionViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallCell", for: indexPath) as! SmallImageCell
        cell.model = items[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 65)
    }
}
