//
//  detailView2.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class detailView2: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /*
    var event: Event?{
        didSet{
            
        }
    }*/
    
    var subView: songOverlayView?
    var added: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
        let nib = UINib(nibName: "songSearchResultsOverlay", bundle: nil)
        subView = nib.instantiate(withOwner: self, options: nil).first as! songOverlayView
        subView!.frame = CGRect(x: 0, y: 90, width: self.frame.width, height: self.frame.height - 90)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        
        return cell
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        print("recognized editing changed")
        if searchField.text == ""{
            print(0)
            subView?.removeFromSuperview()
            added = false
        }
        else if added == true {
            // update subview text
        }
        else{
            self.addSubview(subView!)
            added = true
        }
    }
    
}
