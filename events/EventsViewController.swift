//
//  EventsViewController.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FoldingCell
import ImagePicker

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, imagePickerDelegate2, UIViewControllerPreviewingDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    let kCloseCellHeight: CGFloat = 144
    let kOpenCellHeight: CGFloat = 541
    var cellHeights: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let bundle = Bundle(path: "events/EventsTableViewPage")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "eventCell")
        tableView.separatorStyle = .none


        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh), name: BashNotifications.refresh, object: nil)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.deleteEvent(_:)), name: BashNotifications.delete, object: nil)
        cellHeights = (0..<AppUser.current.events.count).map { _ in C.CellHeight.close }
        registerForPreviewing(with: self, sourceView: tableView)
        //tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cellHeights = (0..<AppUser.current.events.count).map { _ in C.CellHeight.close }
        tableView.reloadData()
    }

    func refresh(_ notification: Notification) {
        cellHeights = (0..<AppUser.current.events.count).map { _ in C.CellHeight.close }
        tableView.reloadData()
    }

    
    func deleteEvent(_ notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailEventViewController") as? DetailEventViewController
        let event = AppUser.current.events[indexPath.row]
        detailVC?.event = event
        detailVC?.delegate = self
        show(detailVC!, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return cell to present associated with user's events
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        cell.event = AppUser.current.events[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppUser.current.events.count
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

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        //print(location)
        
        guard let indexPath = tableView?.indexPathForRow(at: location)  else {return nil}
        
        guard let cell = tableView?.cellForRow(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailEventViewController") as? DetailEventViewController else { return nil }
        //let row = indexPath.row
        
        let event = AppUser.current.events[indexPath.row]
        detailVC.event = event
        detailVC.delegate = self
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
}
