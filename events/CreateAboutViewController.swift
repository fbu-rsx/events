//
//  CreateEventMiscellaneousViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class CreateAboutViewController: UIViewController {
    let numberOfGuests = (CreateEventMaster.shared.event[EventKey.guestlist.rawValue] as AnyObject).count ?? 0
    //weak var delegate: CreateEventMiscellaneousViewControllerDelegate?
    @IBOutlet weak var costPerPersonText: UILabel!
    @IBOutlet weak var totalCostText: UITextField!
    @IBOutlet weak var aboutText: UITextField!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var sendInvitesButton: UIButton!
    @IBOutlet weak var perPersonText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Event Title Label
        eventTitleLabel.textColor = UIColor(hexString: "#4CB6BE")
        if CreateEventMaster.shared.event[EventKey.name.rawValue] == nil {
            eventTitleLabel.text = "No Event Title"
        }
        eventTitleLabel.text = CreateEventMaster.shared.event[EventKey.name.rawValue] as? String
        // Event Time Label
        eventTimeLabel.textColor = UIColor(hexString: "#484848")
        eventTimeLabel.text = CreateEventMaster.shared.event[EventKey.date.rawValue] as? String
        // Total Cost Text Field
        totalCostText.textColor = UIColor(hexString: "#4CB6BE")
        totalCostText.setBottomBorder()
        // Cost Per Person Label
        costPerPersonText.textColor = UIColor(hexString: "#4CB6BE")
        perPersonText.textColor = UIColor(hexString: "#484848")
        // Notes about Event Text Field
        aboutText.textColor = UIColor(hexString: "#4CB6BE")
        aboutText.setBottomBorder()
        // Send Invites Button
        sendInvitesButton.layer.cornerRadius = 5
        sendInvitesButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        // Hide tab bar controller
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func calculateCostPerPerson(_ sender: Any) {
        let totalCost = Double(totalCostText.text!) ?? 0
        let totalAttendees = Double(numberOfGuests + 1)
        let costPerPerson = totalCost / totalAttendees
        costPerPersonText.text = String(format: "$%.2f", costPerPerson)
    }
    
    @IBAction func onCreate(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.cost.rawValue] = totalCostText.text
        CreateEventMaster.shared.event[EventKey.about.rawValue] = aboutText.text
        print(CreateEventMaster.shared.event)
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
