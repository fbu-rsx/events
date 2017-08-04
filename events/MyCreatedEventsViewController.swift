//
//  MyCreatedEventsViewController.swift
//  events
//
//  Created by Xiu Chen on 8/3/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import ImagePicker
import XLPagerTabStrip

class MyCreatedEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, imagePickerDelegate2, UIViewControllerPreviewingDelegate, IndicatorInfoProvider{
    
    @IBOutlet weak var tableView: UITableView!
    
    let kCloseCellHeight: CGFloat = 144
    let kOpenCellHeight: CGFloat = 541
    var cellHeights: [CGFloat] = []
    var myEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        filterMyEvents()
        let bundle = Bundle(path: "events/EventsTableViewPage")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "eventCell")
        tableView.separatorStyle = .none
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyCreatedEventsViewController .refresh), name: BashNotifications.refresh, object: nil)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MyCreatedEventsViewController.deleteEvent(_:)), name: BashNotifications.delete, object: nil)
        cellHeights = (0..<myEvents.count).map { _ in C.CellHeight.close }
        //tableView.reloadData()
        
        self.registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellHeights = (0..<myEvents.count).map { _ in C.CellHeight.close }
        tableView.reloadData()
    }
    
    func filterMyEvents() {
        for event in AppUser.current.events {
            if event.organizer.uid == AppUser.current.uid {
                self.myEvents.append(event)
            }
        }
    }
    
    
    func refresh(_ notification: Notification) {
        //let event = notification.object as! Event
        //self.events.append(event)
        //events = AppUser.current.events
        cellHeights = (0..<myEvents.count).map { _ in C.CellHeight.close }
        tableView.reloadData()
    }
    
    
    func deleteEvent(_ notification: NSNotification) {
        //let event = notification.object as! Event
        //let index = AppUser.current.events.index(of: event)!
        //self.events.remove(at: index)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return cell to present associated with user's events
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        cell.event = myEvents[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myEvents.count
    }
    
    fileprivate struct C {
        struct CellHeight {
            static let close: CGFloat = 144 // equal or greater foregroundView height
            static let open: CGFloat = 541 // equal or greater containerView height
        }
    }
    
    func presenter(imagePicker : ImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blah = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = blah.instantiateViewController(withIdentifier: "DetailEventViewController") as! DetailEventViewController
        let event = AppUser.current.events[indexPath.row]
        detailVC.event = event
        detailVC.delegate = self
        self.navigationController?.pushViewController(detailVC, animated: true)
        //show(detailVC, sender: nil)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView?.indexPathForRow(at: location)  else {return nil}
        
        guard let cell = tableView?.cellForRow(at: indexPath) else { return nil }
        let blah = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC =  blah.instantiateViewController(withIdentifier: "DetailEventViewController") as? DetailEventViewController else { return nil }
        
        let event = myEvents[indexPath.row]
        detailVC.event = event
        detailVC.delegate = self
        
        
        //detailVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        previewingContext.sourceRect = cell.frame
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Created Events")
    }
}


