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
            requestedDate.text = Utilities.getDateString(date: transaction.date)
            eventName.text = transaction.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set default Pay and Details UI
        payButton.layer.cornerRadius = 5
        payButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        // Rounded corners for UIView
        cellView.layer.cornerRadius = 10
        cellView.layer.masksToBounds = true
    }
    
   
    
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    
}
