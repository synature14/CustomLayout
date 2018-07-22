//
//  ViewController.swift
//  CustomLayout
//
//  Created by sutie on 2018. 7. 15..
//  Copyright © 2018년 sutie. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: PhotoLayoutDelegate {
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
    
    func switchCell() -> Bool {
        if layoutType == .custom {
            return false
        } else {
            return true
        }
    }
}


class ViewController: UIViewController {
    
    enum LayoutType {
        case custom, flow
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [UIImage(named: "01")]
    var layoutType: LayoutType = .custom
    
    let oneLayout = OnePhotoLayout()
    let twoLayout = TwoPhotosLayout()
    let threeLayout = ThreePhotosLayout()
    let fourLayout = FourPhotosLayout()
    let fiveLayout = FivePhotosLayout()
//    let flowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneLayout.delegate = self
        twoLayout.delegate = self
        threeLayout.delegate = self
        fourLayout.delegate = self
        fiveLayout.delegate = self

//        flowLayout.scrollDirection = .horizontal

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
            layoutType = .custom
            collectionView.setCollectionViewLayout(twoLayout, animated: true)
        case 3:
            layoutType = .custom
            collectionView.setCollectionViewLayout(threeLayout, animated: true)
        case 4:
            layoutType = .custom
            collectionView.setCollectionViewLayout(fourLayout, animated: true)
        case 5:
            layoutType = .custom
            collectionView.setCollectionViewLayout(fiveLayout, animated: true)
        case 6:
            layoutType = .flow
            collectionView.setCollectionViewLayout(oneLayout, animated: true)
        default:
            break
        }
        
        collectionView.reloadData()
//        collectionView.collectionViewLayout.invalidateLayout()
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch layoutType {
        case .custom:
            return images.count
        case .flow:
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch layoutType {
        case .custom:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell
            cell?.eachImageView.image = images[indexPath.item]
            return cell ?? UICollectionViewCell()

        case .flow:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MultiCollectionCell", for: indexPath) as! MultiImageCollectionViewCell
            cell.setModels(bigItem: images.first!, items: images as! [UIImage])
            return cell

        }
    }
}

//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
//    }
//}





