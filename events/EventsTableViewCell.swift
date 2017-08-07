//
//  EventsTableViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage

class EventsTableViewCell: UITableViewCell{
    
    @IBOutlet weak var sideBar: UIView!
    
    @IBOutlet weak var oneCell: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var closedProfileImageView: UIImageView!
    @IBOutlet weak var closedEventTitle: UILabel!
    @IBOutlet weak var closedEventTime: UILabel!
    @IBOutlet weak var closedUserCost: UILabel!
    @IBOutlet weak var closedInvitedNum: UILabel!
    @IBOutlet weak var closedComingNum: UILabel!
    @IBOutlet weak var responseIcon: UIImageView!
    var canDeleteMyEvent = false
    
    weak var event: Event? {
        didSet{
            if self.event == nil {
                return
            }
            
            self.selectionStyle = .none
            
            
            oneCell.layer.cornerRadius = 5
            oneCell.layer.masksToBounds = true
            
            FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizer.uid)!) { (user: AppUser) in
                // Set organizer's profile picture
                let url = URL(string: user.photoURLString)
                self.closedProfileImageView.af_setImage(withURL: url!)
                // Set event title
                self.closedEventTitle.text = self.event!.title
                // Set and format event location
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                self.closedEventTime.text = dateFormatter.string(from: self.event!.date)
                //Set total cost
                if let cost = self.event!.cost, cost > 0.00999 {
                    self.closedUserCost.text = String(format: "$%.2f", cost)
                } else{
                    self.closedUserCost.text = "Free"
                }
                //Set number of guests invited
                self.closedInvitedNum.text = String(self.event!.guestlist.count)
                // accepted num will eventually be added to Event class
                var coming: Int = 0
                for user in self.event!.guestlist.keys{
                    if self.event!.guestlist[user] == InviteStatus.accepted.rawValue {coming += 1}
                }
                self.closedComingNum.text = String(coming)
                // Set the cell color depending on invite status
                var color: UIColor!
                var sideBarColor: UIColor!
                var backViewColor: UIColor!
                // var backViewColor: UIColor!
                
                
                
                // check if the event is created by AppUser.current
                let eventOrganizer = (self.event?.organizer)!
                
                if eventOrganizer.uid == AppUser.current.uid {
                    
                    self.oneCell.backgroundColor = UIColor(hexString: "#B6A6CA")
                    self.sideBar.backgroundColor = UIColor(hexString: "#D5CFE1")
                    
                    
                    // if my event, hide "accept" and "decline" buttons
                    self.acceptButton.isHidden = true
                    self.declineButton.isHidden = true
                    self.deleteButton.backgroundColor = UIColor(hexString: "#F4ABB1")
                    self.deleteButton.isHidden = false
                    self.deleteButton.layer.cornerRadius = 5
                    
                    // Setting resposne icon to a star
                    self.responseIcon.image = UIImage(named: "my-event")
                    
                } else {
                    switch self.event!.myStatus {
                    case .accepted:
                        color = Colors.greenAccepted
                        sideBarColor = UIColor(hexString: "#8CF7AC")
                        backViewColor = UIColor(hexString: "#8CF7AC")
                        // if accepted, hide "accept" and "decline" buttons
                        self.acceptButton.isHidden = true
                        self.declineButton.isHidden = true
                        self.deleteButton.isHidden = true
                        
                        // Setting resposne icon to a check mark
                        self.responseIcon.image = UIImage(named: "going")
                        
                    case .declined:
                        color = Colors.redDeclined
                        backViewColor = UIColor(hexString: "#F4ABB1")
                        sideBarColor = UIColor(hexString: "#F4ABB1")
                        // if declined, hide "accept" and "decline" buttons
                        self.acceptButton.isHidden = true
                        self.declineButton.isHidden = true
                        self.responseIcon.image = UIImage(named: "not-going")
                        self.deleteButton.isHidden = true
                        
                    default:
                        color = Colors.pendingBlue
                        sideBarColor = UIColor(hexString: "#ABEEFC")
                        backViewColor = UIColor(hexString: "#ABEEFC")
                        self.acceptButton.isHidden = false
                        self.declineButton.isHidden = false
                        self.deleteButton.isHidden = true
                        
                    }
                    self.sideBar.backgroundColor = sideBarColor
                    
                    self.oneCell.backgroundColor = color
                    
                }
            }
        }
    }
    
    override func awakeFromNib() {
        // Initialization code
        
        closedProfileImageView.layer.cornerRadius = closedProfileImageView.bounds.width/2
        closedProfileImageView.layer.masksToBounds = true
        super.awakeFromNib()
        //closedProfileImageView.image = UIImage(named: "icon-avatar-60x60.png")
        acceptButton.layer.cornerRadius = 5
        acceptButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        declineButton.layer.cornerRadius = 5
        declineButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        deleteButton.isHidden = true
    }
    
    @IBAction func onAccept(_ sender: Any) {
        AppUser.current.accept(event: event!)
        NotificationCenter.default.post(name: BashNotifications.accept, object: event)
    }
    
    @IBAction func onDecline(_ sender: Any) {
        AppUser.current.decline(event: event!)
        NotificationCenter.default.post(name: BashNotifications.decline, object: event)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        AppUser.current.delete(event: event!)
        NotificationCenter.default.post(name: BashNotifications.delete, object: event)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
