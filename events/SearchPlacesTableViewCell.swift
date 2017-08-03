//
//  SearchPlacesTableViewCell.swift
//  events
//
//  Created by Skyler Ruesga on 8/3/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchPlacesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var prediction: GMSAutocompletePrediction! {
        didSet {
            titleLabel.attributedText = highlightMatching(prediction.attributedPrimaryText.mutableCopy() as! NSMutableAttributedString)
            addressLabel.attributedText = highlightMatching(prediction.attributedSecondaryText?.mutableCopy() as! NSMutableAttributedString)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func highlightMatching(_ bolded: NSMutableAttributedString) -> NSMutableAttributedString {
        let regularFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        let boldFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        
        bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, in: NSMakeRange(0, bolded.length), options: []) {
            (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let font = (value == nil) ? regularFont : boldFont
            bolded.addAttribute(NSFontAttributeName, value: font, range: range)
        }
        return bolded
    }
}
