//
//  CreateEventTitleViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import DateTimePicker

class CreateTitleViewController: UIViewController {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var createAnEventText: UILabel!
    @IBOutlet weak var currentTimeText: UILabel!
    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.eventTitle.textColor = UIColor(hexString: "#4CB6BE")
        eventTitle.setBottomBorder()
        self.createAnEventText.textColor = UIColor(hexString: "#484848")
        self.currentTimeText.textColor = UIColor(hexString: "#484848")
        selectTimeButton.layer.cornerRadius = 5
        selectTimeButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "MMM d, h:mm a"
        //        eventTime.text = formatter.string(from: datePicker.date)\
        
        self.tabBarController?.tabBar.isHidden = false
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        self.eventTime.text = dateFormatter.string(from: date)
      
    }
    
    // Bounce up-and-down animation for photo
    func mapAnimation() {
        UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
            self.logoImage.frame.origin.y -= 10
        })
        self.logoImage.frame.origin.y += 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.logoImage.layer.removeAllAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let title = CreateEventMaster.shared.event[EventKey.name.rawValue] as? String {
            eventTitle.text = title
        }
        
        if let selected = CreateEventMaster.shared.event[EventKey.date.rawValue]  {
            let dateConverter = DateFormatter()
            dateConverter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            let date = dateConverter.date(from: selected as! String)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            self.eventTime.text = dateFormatter.string(from: date)
        }
    }
    
    @IBAction func onSelectTime(_ sender: Any) {
        dateTimePicker()
        
    }
    
    // DateTimePicker Pod
    func dateTimePicker () {
        let picker = DateTimePicker.show()
        picker.highlightColor = UIColor(hexString: "#FEB2A4")
        picker.isDatePickerOnly = false
        picker.selectedDate = Date()
        picker.dateFormat = "MMM d, h:mm a"
        picker.is12HourFormat = true
        picker.dateFormat = "MMM d, YYYY H:mm a"
        picker.completionHandler = { date in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            self.eventTime.text = dateFormatter.string(from: picker.selectedDate)
            CreateEventMaster.shared.event[EventKey.date.rawValue] = self.eventTime.text
            // do something after tapping done
            
            CreateEventMaster.shared.event[EventKey.date.rawValue] = date.description
        }
    }
    
    @IBAction func didSetTitle(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.name.rawValue] = eventTitle.text
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

// Enable the use of hex codes
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

// Shows a line under text field
extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 0.0
    }
}
