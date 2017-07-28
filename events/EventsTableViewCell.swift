//
//  EventsTableViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage
import FoldingCell

class EventsTableViewCell: FoldingCell, UIScrollViewDelegate {
    
    @IBOutlet weak var sideBar: UIView!
    @IBOutlet weak var sideBar1: UIView!
    @IBOutlet weak var oneCell: RotatedView!
    @IBOutlet weak var view1topConstraint: NSLayoutConstraint!
    @IBOutlet weak var view1: RotatedView!
    @IBOutlet weak var view2: RotatedView!
    @IBOutlet weak var view2topConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var closedProfileImageView: UIImageView!
    @IBOutlet weak var closedEventTitle: UILabel!
    @IBOutlet weak var closedEventTime: UILabel!
    @IBOutlet weak var closedUserCost: UILabel!
    @IBOutlet weak var closedInvitedNum: UILabel!
    @IBOutlet weak var closedComingNum: UILabel!
    
    var pageView : UIPageControl = UIPageControl()
    @IBOutlet weak var scrollView: UIScrollView!
    
    var delegate: imagePickerDelegate2?{
        didSet{
            pageView = UIPageControl(frame:CGRect(x: (self.view2.frame.width-10)/2 - 10, y: self.view2.frame.height - 40, width: 40, height: 40))
            configurePageControl()
            scrollView.delegate = self
            for index in 0...2 {
                var frame = CGRect.zero
                frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
                //print(frame.origin.x)
                frame.size = self.scrollView.frame.size
                if index == 0{
                    let nib = UINib(nibName: "detailView0", bundle: nil)
                    let subView = nib.instantiate(withOwner: self, options: nil).first as! detailView0
                    subView.event = event
                    subView.frame = frame
                    self.scrollView.addSubview(subView)
                }
                else if index == 1{
                    let nib = UINib(nibName: "detailView1", bundle: nil)
                    let subView = nib.instantiate(withOwner: self, options: nil).first as! detailView1
                    //subView.event = event
                    subView.frame = frame
                    subView.delegate = delegate
                    self.scrollView.addSubview(subView)
                }
                else{
                    let nib = UINib(nibName: "detailView2", bundle: nil)
                    let subView = nib.instantiate(withOwner: self, options: nil).first as! detailView2
                    subView.event = event
                    subView.frame = frame
                    self.scrollView.addSubview(subView)
                }
            }
            
            self.scrollView.isPagingEnabled = true
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 3, height: self.scrollView.frame.size.height)
            //print(self.scrollView.frame.width)
            pageView.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        }
    }
    
    /*
     var eventid: String
     var eventDictionary: [String: Any]
     
     //all below are required in the dictionary user to initialize an event
     var eventname: String
     var totalcost: Float? //optional because may just be a free event
     var date: Date
     var coordinate: CLLocationCoordinate2D
     var radius: Double = 100
     var organizerID: String //uid of the organizer
     var guestlist: [String: Bool] // true if guest attended
     var photos: [String: Bool]
     var about: String //description of event, the description variable as unfortunately taken by Objective C
     */
    
    var event: Event?{
        didSet{
            FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizerID)!) { (user: AppUser) in
                // Set organizer's profile picture
                let url = URL(string: user.photoURLString)
                self.closedProfileImageView.af_setImage(withURL: url!)
                // Set event title
                self.closedEventTitle.text = self.event!.title
                // Set and format event location
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                self.closedEventTime.text = dateFormatter.string(from: self.event!.date)
                // Set total cost

                if let total = self.event!.totalcost {
                    let cost = total/Double(self.event!.guestlist.count + 1)
                    self.closedUserCost.text = String(format: "$%.2f", cost)
                } else{
                    self.closedUserCost.text = "Free"
                }
                
                // Set number of guests invited
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
                switch self.event!.myStatus {
                case .accepted:
                    color = Colors.greenAccepted
                    sideBarColor = UIColor(hexString: "#8CF7AC")
                    backViewColor = UIColor(hexString: "#8CF7AC")
                case .declined:
                    color = Colors.redDeclined
                    backViewColor = UIColor(hexString: "#F4ABB1")
                    sideBarColor = UIColor(hexString: "#F4ABB1")
                default:
                    color = Colors.pendingBlue
                    sideBarColor = UIColor(hexString: "#ABEEFC")
                    backViewColor = UIColor(hexString: "#ABEEFC")
                }
                self.sideBar.backgroundColor = sideBarColor
                self.sideBar1.backgroundColor = sideBarColor
                self.oneCell.backgroundColor = color
                self.backViewColor = backViewColor
            }
        }
    }
    
    override func awakeFromNib() {
        // Initialization code
        foregroundView = view1
        foregroundViewTop = view1topConstraint
        containerView = view2
        containerViewTop = view2topConstraint
        itemCount = 3
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        closedProfileImageView.layer.cornerRadius = closedProfileImageView.bounds.width/2
        closedProfileImageView.layer.masksToBounds = true
        super.awakeFromNib()
        //closedProfileImageView.image = UIImage(named: "icon-avatar-60x60.png")
        
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
        self.pageView.numberOfPages = 3
        self.pageView.currentPage = 0
        self.pageView.tintColor = UIColor.red
        self.pageView.pageIndicatorTintColor = UIColor.black
        self.pageView.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 1, blue: 0.8928422928, alpha: 1)
        self.view2.addSubview(pageView)
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageView.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageView.currentPage = Int(pageNumber)
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
