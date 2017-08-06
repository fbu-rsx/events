//
//  PaymentTableViewCell.swift
//  events
//
//  Created by Xiu Chen on 7/25/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

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
                payButton.titleLabel?.text = "Paid"
                payButton.backgroundColor = Colors.green
            } else {
                payButton.backgroundColor = Colors.coral
                payButton.titleLabel?.text = "Pay"
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
        payButton.isUserInteractionEnabled = false
        payButton.isEnabled = false
        transaction.completeTransaction()
        payButton.titleLabel?.text = "Paid"
        payButton.backgroundColor = Colors.green
    }
   
    
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    
}
