//
//  DetailEventViewController.swift
//  events
//
//  Created by Rhian Chavez on 8/3/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class DetailEventViewController: UIViewController, UIScrollViewDelegate{
    
    var pageView : UIPageControl = UIPageControl()
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var delegate: imagePickerDelegate2? {
        didSet{
            if self.delegate == nil {
                return
            }

            pageView = UIPageControl(frame:CGRect(x: (self.view.frame.width)/2 - 20, y: 578, width: 40, height: 40))
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
                    subView.event = event
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
            self.scrollView.contentSize = CGSize(width: 1125, height: 554)
            pageView.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        }
    }
    
    weak var event: Event? {
        didSet{
            if self.event == nil {
                return
            }
            FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizer.uid)!) { (user: AppUser) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"

                var coming: Int = 0
                for user in self.event!.guestlist.keys{
                    if self.event!.guestlist[user] == InviteStatus.accepted.rawValue {coming += 1}
                }

            }
        }
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageView.numberOfPages = 3
        self.pageView.currentPage = 0
        self.pageView.tintColor = UIColor.red
        self.pageView.pageIndicatorTintColor = UIColor.black
        self.pageView.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 1, blue: 0.8928422928, alpha: 1)
        self.view.addSubview(pageView)
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageView.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageView.currentPage = Int(pageNumber)
    }
    
    override var previewActionItems: [UIPreviewActionItem]{
        let acceptAction = UIPreviewAction(title: "Accept", style: .default) { (action, viewController) -> Void in
            // do stuff that accepts event invite
        }
        
        let declineAction = UIPreviewAction(title: "Decline", style: .destructive) { (action, viewController) -> Void in
            // do stuff the declines event invite
        }
        if event?.organizer.uid == AppUser.current.uid{
            return []
        }
        return [acceptAction, declineAction]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
