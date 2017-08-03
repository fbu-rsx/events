//
//  DetailMediaViewController.swift
//  events
//
//  Created by Rhian Chavez on 8/2/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class DetailMediaViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    var pic: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = pic
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
