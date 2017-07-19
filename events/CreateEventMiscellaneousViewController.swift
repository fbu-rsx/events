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
    var event: [String: Any] = [:]
    var ContactsPhone: [String] = []
    var delegate: CreateEventMiscellaneousViewControllerDelegate?
    @IBOutlet weak var costPerPersonText: UILabel!
    @IBOutlet weak var totalCostText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(hexString: "#1abc9c")
        costPerPersonText.layer.borderWidth = 1.0
        costPerPersonText.layer.cornerRadius = 8
        costPerPersonText.layer.borderColor = UIColor.white.cgColor
        
        print(ContactsPhone.count)
    }
    
    
    @IBAction func calculateCostPerPerson(_ sender: Any) {
        let totalCost = Double(totalCostText.text!) ?? 0
        let numberofGuests = ContactsPhone.count
        let totalAttendees = Double(numberofGuests + 1)
        let costPerPerson = totalCost / totalAttendees
        print(totalCost)
        print(totalAttendees)
        print(costPerPerson)
        costPerPersonText.text = String(format: "$%.2f", costPerPerson)
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
