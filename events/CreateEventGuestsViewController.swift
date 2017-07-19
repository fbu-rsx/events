//
//  CreateEventGuestsViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import EVContactsPicker

class CreateEventGuestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EVContactsPickerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
    var selectedContacts: [EVContactProtocol] = []
    var selectedContactsPhone: [String] = []
    var event: [String: Any] = [:]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // DISPLAY: Background color
        self.view.backgroundColor = UIColor(hexString: "#9b59b6")
        // DISPLAY: Rounded buttons
        inviteButton.layer.cornerRadius = 5
        inviteButton.layer.borderWidth = 1
        inviteButton.layer.borderColor = UIColor.white.cgColor
        inviteButton.clipsToBounds = true
        // DISPLAY: Hide navigation controller
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func onClickInvite(_ sender: Any) {
        showPicker()
    }
    
    func showPicker() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let contactPicker = EVContactsPickerViewController()
        contactPicker.delegate = self
        self.navigationController?.pushViewController(contactPicker, animated: true)
    }
    
    func didChooseContacts(_ contacts: [EVContactProtocol]?) {
        if let cons = contacts {
            for con in cons {
                if !(selectedContacts.contains(where: {$0.phone == con.phone})) {
                    selectedContacts.append(con)
                    selectedContactsPhone.append(con.phone!)
                }
            }
        }
        tableView.reloadData()
        print(selectedContactsPhone.count)
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    // TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedContacts.isEmpty {
            return 0
        } else {
            return selectedContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuestListCell", for: indexPath) as! GuestListTableViewCell
        let guest = selectedContacts[indexPath.row]
        
        let firstName = guest.firstName!
        let lastName = guest.lastName!
        let fullName = "\(String(describing: firstName)) \(String(describing: lastName))"
        let phoneNumber = guest.phone
        
        cell.guestName.text = fullName
        cell.guestCell.text = phoneNumber
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMiscellaneous" {
            // Guest List in Event dictionary will consist of all phone numbers
            self.event["guestlist"] = self.selectedContactsPhone
            let createEventMiscellaneousViewController = segue.destination as! CreateEventMiscellaneousViewController
            createEventMiscellaneousViewController.event = self.event
            createEventMiscellaneousViewController.ContactsPhone = self.selectedContactsPhone
        }
    }
    
    
}


