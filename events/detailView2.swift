//
//  detailView2.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class detailView2: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /*
    var event: Event?{
        didSet{
            
        }
    }*/
    
    @IBAction func spotifyTap(_ sender: UIButton) {
//        OAuthSwiftManager.shared.logout()
        OAuthSwiftManager.shared.spotifyLogin(success: {
            print("somethign worked")
        }) { (Error) in
            print("didn't work")
        }
        }

    @IBAction func test(_ sender: UIButton) {
        OAuthSwiftManager.shared.createPlaylist(name: "test", completion: {})
    }
}
