//
//  CreateEventMiscellaneousViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class CreateEventMiscellaneousViewController: UIViewController {
    let numberOfGuests = (CreateEventMaster.shared.event["guestlist"] as AnyObject).count ?? 0
    //var delegate: CreateEventMiscellaneousViewControllerDelegate?
    @IBOutlet weak var costPerPersonText: UILabel!
    @IBOutlet weak var totalCostText: UITextField!
    @IBOutlet weak var aboutText: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(hexString: "#1abc9c")
        costPerPersonText.layer.borderWidth = 1.0
        costPerPersonText.layer.cornerRadius = 8
        costPerPersonText.layer.borderColor = UIColor.white.cgColor
        
    }
    
    
    @IBAction func calculateCostPerPerson(_ sender: Any) {
        let totalCost = Double(totalCostText.text!) ?? 0
        let totalAttendees = Double(numberOfGuests + 1)
        let costPerPerson = totalCost / totalAttendees
        costPerPersonText.text = String(format: "$%.2f", costPerPerson)
    }

    @IBAction func onCreate(_ sender: Any) {
        CreateEventMaster.shared.event["totalcost"] = totalCostText.text
        CreateEventMaster.shared.event["about"] = aboutText.text
        CreateEventMaster.shared.event["organizerID"] = AppUser.current.uid
        createEvent(Event(dictionary: CreateEventMaster.shared.event))
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
        CreateEventMaster.shared.delegate?.didCreateNewEvent(event)
        self.dismiss(animated: true, completion: nil)
        CreateEventMaster.shared = CreateEventMaster()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
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
