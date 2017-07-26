//
//  PaymentTableViewCell.swift
//  events
//
//  Created by Xiu Chen on 7/25/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentValueLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var requesterImage: UIImageView!
    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var requestedDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
