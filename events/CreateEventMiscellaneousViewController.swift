//
//  CreateEventMiscellaneousViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

protocol CreateEventMiscellaneousViewControllerDelegate {
    func didCreateNewEvent(_ event: Event)
}

class CreateEventMiscellaneousViewController: UIViewController {
    
<<<<<<< HEAD
    var event: [String: Any] = [:]
=======
    var delegate: CreateEventMiscellaneousViewControllerDelegate?
>>>>>>> 33c8322621ad0f949cda2520ed4e521df2c8ba3a

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(hexString: "#1abc9c")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     * Call this function once Event object is created
     * and you are ready to dismis this view controller
     * to go back to the MapViewController
     */
    func createEvent(_ event: Event) {
        delegate?.didCreateNewEvent(event)
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
