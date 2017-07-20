//
//  Storyboards.swift
//  events
//
//  Created by Rhian Chavez on 7/19/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//
/*
import Foundation
import Foundation

#if os(iOS)
    import UIKit
    public typealias OAuthStoryboard = UIStoryboard
    public typealias OAuthStoryboardSegue = UIStoryboardSegue
    
#elseif os(OSX)
    import AppKit
    public typealias OAuthStoryboard = NSStoryboard
    public typealias OAuthStoryboardSegue = NSStoryboardSegue
#endif


struct Storyboards {
    struct Main {
        
        static let identifier = "Storyboard"
        
        static var storyboard: OAuthStoryboard {
            return OAuthStoryboard(name: self.identifier, bundle: nil)
        }
        
        static func instantiateForm() -> FormViewController {
            #if os(iOS)
                return self.storyboard.instantiateViewController(withIdentifier: "Form") as! FormViewController
            #elseif os(OSX)
                return self.storyboard.instantiateController(withIdentifier: "Form") as! FormViewController
            #endif
        }
        
        static let FormSegue = "form"
        
    }
}*/
