//
//  CreateEventTitleViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class CreateEventTitleViewController: UIViewController {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#e74c3c")
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        eventTime.text = formatter.string(from: datePicker.date)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let title = CreateEventMaster.shared.event[EventKey.name.rawValue] as? String {
            eventTitle.text = title
        }
    }
    
    @IBAction func didSetTitle(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.name.rawValue] = eventTitle.text
    }
    
    @IBAction func didSetDate(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.date.rawValue] = datePicker.date.description

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        eventTime.text = formatter.string(from: datePicker.date)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        if valid() {
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    @IBAction func didHitExitButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func valid() -> Bool {
        let a = CreateEventMaster.shared.event[EventKey.name.rawValue] != nil
        let b = CreateEventMaster.shared.event[EventKey.date.rawValue] != nil
        return a && b
    }

}


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
