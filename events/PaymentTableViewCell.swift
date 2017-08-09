//
//  PaymentTableViewCell.swift
//  events
//
//  Created by Xiu Chen on 7/25/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import SCLAlertView

class PaymentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var paymentValueLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var requesterImage: UIImageView!
    @IBOutlet weak var requestedDate: UILabel!
    @IBOutlet weak var eventName: UILabel!
    
    var transaction: Transaction! {
        didSet {
            paymentValueLabel.text = String(format: "%.2f", transaction.amount)
            requesterImage.af_setImage(withURL: URL(string: transaction.receiver.photoURLString)!)
            requesterImage.layer.cornerRadius = 0.5 * requesterImage.frame.width
            requesterImage.layer.masksToBounds = true
            requestedDate.text = Utilities.getDateString(date: transaction.date)
            eventName.text = transaction.name
            if transaction.status == true { // I have paid
                payButton.isUserInteractionEnabled = false
                payButton.isEnabled = false
                payButton.setTitle("Paid", for: .normal)
                payButton.backgroundColor = Colors.green
            } else {
                payButton.backgroundColor = Colors.coral
                payButton.setTitle("Pay", for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set default Pay and Details UI
        payButton.layer.cornerRadius = 5
        // Rounded corners for UIView
        cellView.layer.cornerRadius = 10
        cellView.layer.masksToBounds = true
    }
    
    @IBAction func didTapPay(_ sender: Any) {
        if AppUser.current.wallet - transaction.amount > 0 {
            payButton.isUserInteractionEnabled = false
            payButton.isEnabled = false
            transaction.completeTransaction()
            payButton.setTitle("Paid", for: .normal)
            payButton.backgroundColor = Colors.green
            print("pay complete")
        } else {
            let alertView = SCLAlertView()
            alertView.addButton("Ok", action: { 
                alertView.dismiss(animated: true, completion: nil)
            })
            alertView.showTitle("Insufficient Funds", subTitle: "Add money to complete transaction.", style: SCLAlertViewStyle.error, closeButtonTitle: nil, duration: 4, colorStyle: Colors.coral.getUInt(), colorTextButton: UIColor.white.getUInt(), circleIconImage: nil, animationStyle: .topToBottom)

        }
    }
}
