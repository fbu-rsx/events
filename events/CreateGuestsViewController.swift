//
//  CreateEventGuestsViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class CreateGuestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var friends: [FacebookFriend]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    
        self.titleLabel.textColor = UIColor(hexString: "#FEB2A4")
        
        self.friends = AppUser.current.facebookFriends
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuestListCell", for: indexPath) as! GuestListTableViewCell
        cell.guestName.textColor = UIColor.darkGray
        cell.guestImage.layer.cornerRadius = 5
        cell.guestImage.layer.borderWidth = 1
        cell.guestImage.layer.borderColor = UIColor.white.cgColor
        cell.guestImage.backgroundColor = UIColor(hexString: "#FEB2A4")
        cell.guestImage.clipsToBounds = true
        let guest = friends[indexPath.row]
        cell.guestImage.af_setImage(withURL: guest.photo)
        cell.guestName.text = guest.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            CreateEventMaster.shared.guestlist[friends[indexPath.row].id] = nil
        } else {
            cell.accessoryType = .checkmark
            CreateEventMaster.shared.guestlist[friends[indexPath.row].id] = InviteStatus.noResponse.rawValue
        }
        print(CreateEventMaster.shared.guestlist)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


