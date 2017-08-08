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
    @IBOutlet weak var eventTitle: UITextView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var createAnEventText: UILabel!
    @IBOutlet weak var currentTimeText: UILabel!
    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var rightArrowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventTitle.textColor = UIColor.lightGray
        self.eventTitle.delegate = self
        eventTitle.setBottomBorder()
        self.createAnEventText.textColor = UIColor(hexString: "#484848")
        self.currentTimeText.textColor = UIColor(hexString: "#484848")
        selectTimeButton.layer.cornerRadius = 5
        selectTimeButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        self.eventTime.textColor = UIColor.lightGray
        self.tabBarController?.tabBar.isHidden = false
        self.updatePageController()
    }
    
    // Bounce up-and-down animation for photo
    func mapAnimation() {
        UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
            self.logoImage.frame.origin.y -= 10
        })
        self.logoImage.frame.origin.y += 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapAnimation()
        self.updatePageController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.logoImage.layer.removeAllAnimations()
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
        picker.completionHandler = { date in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            self.eventTime.text = dateFormatter.string(from: picker.selectedDate)
            self.eventTime.textColor = UIColor(hexString: "#FEB2A4")
            
            CreateEventMaster.shared.event[EventKey.date] = date.description
            self.updatePageController()
        }
    }
    
    @IBAction func didTapDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func updatePageController() {
        if valid() {
            rightArrowButton.isUserInteractionEnabled = true
            rightArrowButton.imageView!.image = UIImage(named: "right-arrow-green")
            NotificationCenter.default.post(name: BashNotifications.enableSwipe, object: nil)
            Utilities.shrinkAndGrowAnimation(button: rightArrowButton)
        } else {
            rightArrowButton.isUserInteractionEnabled = false
            rightArrowButton.imageView!.image = UIImage(named: "right-arrow-gray")
            NotificationCenter.default.post(name: BashNotifications.disableSwipe, object: nil)
        }
    }
    func valid() -> Bool {
        let name = CreateEventMaster.shared.event[EventKey.name] as? String
        let nameExists = name != nil && name != "enter a title"
        let dateExists = CreateEventMaster.shared.event[EventKey.date] != nil
        return nameExists && dateExists
    }
    
    @IBAction func hitRightArrow(_ sender: Any) {
        rightArrowButton.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeRight, object: nil)
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



extension CreateTitleViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "enter a title")
        {
            textView.text = ""
            textView.textColor = UIColor(hexString: "#4CB6BE")
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "")
        {
            textView.text = "enter a title"
            textView.textColor = .lightGray
        }
        if let title = eventTitle.text, title != "enter a title" {
            CreateEventMaster.shared.event[EventKey.name] = title
            
        }
        self.updatePageController()

        textView.resignFirstResponder()
    }
}

extension UITextView {
    func setBottomBorder() {
        
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        bottomBorder.frame = CGRect(x: 0, y: self.frame.maxY - 1, width: self.frame.width, height: 1)
        bottomBorder.name = "BottomBorder"
        layer.addSublayer(bottomBorder)
        
        //            let topBorder = CALayer()
        //            topBorder.backgroundColor = UIColor.lightGray.cgColor
        //            topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), 1)
        //            topBorder.name = "TopBorder"
        //            layer.addSublayer(topBorder)
    }
}

// Shows a line under text field
extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 0.0
    }
}
