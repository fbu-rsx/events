//
//  EVContactBubble.swift
//  Pods
//
//  Created by Edward Valentini on 8/29/15.
//
//

import Foundation
import UIKit
import QuartzCore

class EVContactBubble: UIView, UITextViewDelegate {
    var name : String?
    var label : UILabel?
    var textView : UITextView?
    var isSelected : Bool = false
    var delegate : EVContactBubbleDelegate?
    var gradientLayer : CAGradientLayer?
    
    let kBubbleColor = UIColor(red: 24.0/255.0, green: 134.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    let kBubbleColorSelected = UIColor(red: 151.0/255.0, green: 199.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    let kHorizontalPadding = CGFloat(10.0)
    let kVerticalPadding = CGFloat(2.0)
    
    var color : EVBubbleColor?
    var selectedColor : EVBubbleColor?
    
    convenience init(name: String) {
        self.init(name: name, color: nil, selectedColor: nil)
    }
    
    init(name: String, color: EVBubbleColor?, selectedColor: EVBubbleColor?) {
        super.init(frame: CGRect.zero)
        self.name = name
        self.color = color ?? EVBubbleColor(gradientTop: kBubbleColor, gradientBottom: kBubbleColor, border: kBubbleColor)
        self.selectedColor = selectedColor ?? EVBubbleColor(gradientTop: kBubbleColorSelected, gradientBottom: kBubbleColorSelected, border: kBubbleColorSelected)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setFont(_ font: UIFont) -> Void {
        self.label?.font = font
        
    }
    
    func setupView() -> Void {
        self.label = UILabel()
        self.label?.backgroundColor = UIColor.clear
        self.label?.text = self.name!
        self.addSubview(self.label!)
        
        self.textView = UITextView()
        self.textView?.delegate = self
        self.textView?.isHidden = true
        self.addSubview(self.textView!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EVContactBubble.handleTapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
        
        self.adjustSize()
        self.unSelect()
    }
    
    func adjustSize() -> Void {
        self.label?.sizeToFit()
        var frame = self.label?.frame
        frame?.origin.x = kHorizontalPadding
        frame?.origin.y = kVerticalPadding
        
        self.label?.frame = frame!
        
        self.bounds = CGRect(x: 0, y: 0,  width: frame!.size.width + 2 * kHorizontalPadding, height: frame!.size.height + 2 * kVerticalPadding)
        
        if(self.gradientLayer == nil ) {
            self.gradientLayer = CAGradientLayer()
            self.layer.insertSublayer(self.gradientLayer!, at: 0)
        }
        self.gradientLayer?.frame = self.bounds
        
        let viewLayer = self.layer
        viewLayer.cornerRadius = self.bounds.size.height / 2.0
        viewLayer.borderWidth = 1.0
        viewLayer.masksToBounds = true
    }
    
    func select() -> Void {
        self.delegate?.contactBubbleWasSelected(self)
        
        let viewLayer = self.layer
        
        viewLayer.borderColor = self.selectedColor?.border?.cgColor
        
        let xxx = self.selectedColor?.gradientTop?.cgColor
        let yyy = self.selectedColor?.gradientBottom?.cgColor
        
        let arr2 = NSArray(arrayLiteral: xxx!,yyy!)
        
        self.gradientLayer?.colors = arr2 as [AnyObject]
    
        self.label?.textColor = UIColor.white
        
        self.isSelected = true
        
        self.textView?.becomeFirstResponder()
    
    }
    
    func unSelect() -> Void {
        let viewLayer = self.layer
        
        viewLayer.borderColor = self.color?.border?.cgColor
        
        
        let xxx = self.color?.gradientTop?.cgColor
        let yyy = self.color?.gradientBottom?.cgColor
        
        let arr2 = NSArray(arrayLiteral: xxx!,yyy!)

        self.gradientLayer?.colors = arr2 as [AnyObject]

        self.label?.textColor = UIColor.white
        
        self.isSelected = false
        
        self.textView?.resignFirstResponder()

        
        
    }
    
    func handleTapGesture() -> Void {
        if(self.isSelected) {
            self.unSelect()
        } else {
            self.select()
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.textView?.isHidden = false
        
        if(text == "\n") {
            return false
        }
        
        if(textView.text == "" && text == "") {
            self.delegate?.contactBubbleShouldBeRemoved(self)
        }
        
        if( self.isSelected ) {
            self.textView?.text = ""
            self.unSelect()
            self.delegate?.contactBubbleWasUnSelected(self)
        }
        
        return true
    }
}
