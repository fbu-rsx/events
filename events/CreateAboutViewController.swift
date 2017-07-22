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
        eventTitleLabel.textColor = UIColor(hexString: "#4CB6BE")
        eventTimeLabel.textColor = UIColor(hexString: "#484848")
        
        totalCostText.textColor = UIColor(hexString: "#4CB6BE")
        totalCostText.setBottomBorder()
        costPerPersonText.textColor = UIColor(hexString: "#4CB6BE")
        perPersonText.textColor = UIColor(hexString: "#484848")
        aboutText.textColor = UIColor(hexString: "#4CB6BE")
        aboutText.setBottomBorder()
        sendInvitesButton.layer.cornerRadius = 5
        sendInvitesButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        
        //        costPerPersonText.layer.borderWidth = 1.0
        //        costPerPersonText.layer.cornerRadius = 8
        //        costPerPersonText.layer.borderColor = UIColor.white.cgColor
        
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
