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

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, imagePickerDelegate2 {

    @IBOutlet weak var tableView: UITableView!
    
    let kCloseCellHeight: CGFloat = 144
    let kOpenCellHeight: CGFloat = 541
    var events: [Event] = []
    var cellHeights: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let bundle = Bundle(path: "events/EventsTableViewPage")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "eventCell")
        tableView.separatorStyle = .none
        self.events = AppUser.current.events
        cellHeights = (0..<events.count).map { _ in C.CellHeight.close }

        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh), name: BashNotifications.refresh, object: nil)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.deleteEvent(_:)), name: BashNotifications.delete, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppUser.current.events.count != self.events.count {
            events = AppUser.current.events
            cellHeights = (0..<AppUser.current.events.count).map { _ in C.CellHeight.close }
            tableView.reloadData()
        }
    }

    func refresh(_ notification: Notification) {
        let event = notification.object as! Event
        self.events.append(event)
        cellHeights = (0..<events.count).map { _ in C.CellHeight.close }
        tableView.reloadData()
    }

    
    func deleteEvent(_ notification: NSNotification) {
        let event = notification.object as! Event
        let index = self.events.index(of: event)!
        self.events.remove(at: index)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return cell to present associated with user's events
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        cell.event = events[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
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
        guard case let cell as FoldingCell = tableView.cellForRow(at: indexPath)
            else {
            return
        }
        
        for heightnum in 0..<cellHeights.count{
            if cellHeights[heightnum] == kOpenCellHeight{
                if heightnum != indexPath.row {
                    return
                }
            }
        }
        
        var duration = 0.0
        
        if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.3
            tableView.isScrollEnabled = false
        } else {// close cell
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.5
            tableView.isScrollEnabled = true
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { 
            tableView.beginUpdates()
            tableView.endUpdates()
        }) { (finished: Bool) in
        }
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let cell as FoldingCell = cell {
            
            cell.backgroundColor = .clear
            if cellHeights[indexPath.row] == C.CellHeight.close {
                cell.unfold(false, animated: false, completion: nil)
            } else {
                cell.unfold(true, animated: false, completion: nil)
            }
        }
    }
}
