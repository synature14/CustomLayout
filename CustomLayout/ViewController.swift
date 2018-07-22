//
//  ViewController.swift
//  CustomLayout
//
//  Created by sutie on 2018. 7. 15..
//  Copyright © 2018년 sutie. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: RDPhotoLayoutDelegate {
    func size(at: IndexPath) -> CGSize {
        
        guard let image = images[at.item] else {
            print("error_")
            return CGSize.zero
        }
        
        let resizedWidth = image.size.width / 2
        let resizedHeight = image.size.height / 2
        print("resizedWidth : \(resizedWidth), resizedHeight: \(resizedHeight)")
        return CGSize(width: resizedWidth, height: resizedHeight)
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [ UIImage(named: "01")]
    
    let oneLayout = OnePhotoLayout()
    let twoLayout = TwoPhotosLayout()
    let threeLayout = ThreePhotosLayout()
    let fourLayout = FourPhotosLayout()
    let fiveLayout = FivePhotosLayout()
    let flowLayout = UICollectionViewFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneLayout.delegate = self
        twoLayout.delegate = self
        threeLayout.delegate = self
        fourLayout.delegate = self
        fiveLayout.delegate = self
        
        collectionView.setCollectionViewLayout(oneLayout, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
        if images.count > 5 {
            print("Done")
            return
        }
        let imageName = "0" + "\(images.count+1)"
        if let image = UIImage(named: imageName) {
            images.append(image)
        } else {
            print("image is not cutie than sutie")
        }
       
        switch images.count {
        case 2:
            collectionView.setCollectionViewLayout(twoLayout, animated: true)
        case 3:
            collectionView.setCollectionViewLayout(threeLayout, animated: true)
        case 4:
            collectionView.setCollectionViewLayout(fourLayout, animated: true)
        case 5:
            collectionView.setCollectionViewLayout(fiveLayout, animated: true)
        default:
            collectionView.setCollectionViewLayout(flowLayout, animated: true)
        }
        collectionView.reloadData()
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return 1
        } else {
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let _ = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MultiImageCell", for: indexPath) as? ImageCollectionViewCell
            return cell ?? UICollectionViewCell()
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell
            cell?.eachImageView.image = images[indexPath.item]
            return cell ?? UICollectionViewCell()
        }
    }
}





