//
//  GuestListTableViewCell.swift
//  events
//
//  Created by Xiu Chen on 7/18/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class GuestListTableViewCell: UITableViewCell {
    @IBOutlet weak var guestName: UILabel!
    @IBOutlet weak var guestCell: UILabel!
    @IBOutlet weak var guestImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
