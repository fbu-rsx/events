//
//  detailView0.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit

class detailView0: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var topMap: MKMapView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func goingTap(_ sender: UIButton) {
    }
    
    
    @IBAction func notGoingTap(_ sender: UIButton) {
    }
    
    var event: Event?{
        didSet{
            
        }
    }
    
}
