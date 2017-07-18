//
//  CreateEventGuestsViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import ContactsUI

class CreateEventGuestsViewController: UIViewController, CNContactPickerDelegate {
    
    var contactStore = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#8e44ad")
        
        self.askForContactAccess()
        
        // Displaying Contacts
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Asking for permission to access user's Contacts book
    func askForContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if !access {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
                            }
                            
                            alertController.addAction(dismissAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        })  
                    }  
                }  
            })  
            break  
        default:  
            break  
        }  
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


//MARK:- CNContactPickerDelegate Method

func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
    contacts.forEach { contact in
        for number in contact.phoneNumbers {
            let phoneNumber = number.value
            print("number is = \(phoneNumber)")
        }
    }
}

func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    print("Cancel Contact Picker")
}
