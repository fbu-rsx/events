//
//  DetailPictureViewController.swift
//  events
//
//  Created by Rhian Chavez on 7/19/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class DetailPictureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(sender)
    }

    @IBAction func download(_ sender: UIButton) {
        // download image to user's phone
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
