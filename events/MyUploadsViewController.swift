//
//  MyUploadsViewController.swift
//  events
//
//  Created by Xiu Chen on 7/26/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MyUploadsViewController: UIViewController, IndicatorInfoProvider, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var photos: [UIImage] = []
    var event: Event? {
        didSet{
            loadImages()
        }
    }
    
    override func viewDidLoad() {
    }
    
    override func awakeFromNib() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let bundle = Bundle(path: "/Users/xiuchen/Desktop/events/events/imageCollectionViewCell.xib")
        let nib = UINib(nibName: "imageCollectionViewCell", bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: "imageCell")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //layout.itemSize = CGSize(width: self.frame.width/3, height: self.frame.width/3)
        layout.sectionInset.left = 0
        layout.sectionInset.right = 0
        layout.sectionInset.bottom = 0
        layout.sectionInset.top = 0
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        loadImages()
    }
    
    func loadImages(){
        for imageID in event!.photos.keys{
            FirebaseStorageManager.shared.downloadImage(event: self.event!, imageID: imageID, completion: { (image, imageID) in
                if self.photos.contains(image) == false {
                    self.photos.append(image)
                    print("here")
                }
                self.collectionView.reloadData()
            })
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Uploads")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCollectionViewCell
        cell.image.image = photos[indexPath.row]
        return cell
    }

}
