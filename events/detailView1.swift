//
//  detailView1.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class detailView1: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewCell: UICollectionViewCell!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        return collectionViewCell
    }
}
