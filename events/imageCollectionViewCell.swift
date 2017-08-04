//
//  imageCollectionViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/28/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class imageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = isSelected ? Colors.coral.cgColor : UIColor.clear.cgColor
        }
    }
    
    
}
