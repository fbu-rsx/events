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
    
    var cellHeight: CGFloat = 144
    var myEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        filterMyEvents()
        let bundle = Bundle(path: "events/EventsTableViewPage")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "eventCell")
        tableView.separatorStyle = .none
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(MyCreatedEventsViewController .refresh), name: BashNotifications.refresh, object: nil)
        // Do any additional setup after loading the view.
   //     NotificationCenter.default.addObserver(self, selector: #selector(MyCreatedEventsViewController.deleteEvent(_:)), name: BashNotifications.delete, object: nil)
        //tableView.reloadData()
        
        self.registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterMyEvents()
        tableView.reloadData()
    }
    
    func filterMyEvents() {
        myEvents = []
        for event in AppUser.current.events {
            if event.organizer.uid == AppUser.current.uid && !myEvents.contains(event) {
                self.myEvents.append(event)
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return cell to present associated with user's events
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        cell.event = myEvents[indexPath.row]
        cell.canDeleteMyEvent = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myEvents.count
    }
    
    func presenter(imagePicker : ImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blah = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = blah.instantiateViewController(withIdentifier: "DetailContainerViewController") as! DetailContainerViewController
        let event = AppUser.current.events[indexPath.row]
        detailVC.event = event
        detailVC.imageDelegate = self
        self.navigationController?.pushViewController(detailVC, animated: true)
        //show(detailVC, sender: nil)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView?.indexPathForRow(at: location)  else {return nil}
        
        guard let cell = tableView?.cellForRow(at: indexPath) else { return nil }
        let blah = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC =  blah.instantiateViewController(withIdentifier: "DetailContainerViewController") as? DetailContainerViewController else { return nil }
        
        let event = myEvents[indexPath.row]
        detailVC.event = event
        detailVC.imageDelegate = self
        
        
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


