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
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    
        self.titleLabel.textColor = UIColor(hexString: "#FEB2A4")
        let bottomBorder = CALayer()
        bottomBorder.borderColor = Colors.coral.cgColor
        bottomBorder.borderWidth = 1.0
        bottomBorder.frame = CGRect(x: -1, y: titleLabel.layer.frame.size.height-1, width: titleLabel.layer.frame.size.width, height: 1)
        titleLabel.layer.addSublayer(bottomBorder)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.separatorColor = Colors.coral
        tableView.separatorStyle = .singleLine
        let bundle = Bundle(path: "events/EventsTableViewPage")
        let nib = UINib(nibName: "GuestsTableViewCell", bundle: bundle)
        tableView.register(nib , forCellReuseIdentifier: "userCell")
        self.tableView.tableFooterView = UIView()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        leftArrowButton.isUserInteractionEnabled = true
        rightArrowButton.isUserInteractionEnabled = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppUser.current.facebookFriends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! GuestsTableViewCell
        cell.nameLabel.textColor = UIColor.darkGray
        cell.selectionStyle = .none
        cell.guestImage.layer.cornerRadius = 0.5 * cell.guestImage.frame.width
        cell.guestImage.layer.borderWidth = 1
        cell.guestImage.layer.borderColor = UIColor.white.cgColor
        cell.guestImage.backgroundColor = UIColor(hexString: "#FEB2A4")
        cell.guestImage.clipsToBounds = true
        let guest = AppUser.current.facebookFriends[indexPath.row]
        cell.guestImage.af_setImage(withURL: guest.photo)
        cell.nameLabel.text = guest.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            CreateEventMaster.shared.guestlist[AppUser.current.facebookFriends[indexPath.row].id] = nil
        } else {
            cell.accessoryType = .checkmark
            CreateEventMaster.shared.guestlist[AppUser.current.facebookFriends[indexPath.row].id] = InviteStatus.noResponse.rawValue
        }
        print(CreateEventMaster.shared.guestlist)
    }
    
    
    
    @IBAction func hitLeftArror(_ sender: Any) {
        leftArrowButton.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeLeft, object: nil)
    }
    
    @IBAction func hitRightArrow(_ sender: Any) {
        rightArrowButton.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeRight, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


