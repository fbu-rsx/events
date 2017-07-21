//
//  EventsViewController.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FirebaseDatabaseUI
import FoldingCell

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let kCloseCellHeight: CGFloat = 144
    let kOpenCellHeight: CGFloat = 400
    var events: [Event] = []
    var cellHeights: [CGFloat] = []
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        //let bundle = Bundle(path: "/Users/rhianchavez11/Documents/events/events/Views")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        events = AppUser.current.events
        tableView.separatorStyle = .none
        //cellHeights = (0..<events.count).map { _ in C.CellHeight.close }
        cellHeights = (0..<6).map { _ in C.CellHeight.close }
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.frame.size.width = view.frame.size.width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return cell to present associated with user's events 
        // which data to display is dependent on selected index of segmented control
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        // see which data to display
        //print(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of events associated with user in current section
        // number will be dependent on selected index of segmented control
        //return events.count
        return 5
    }
    
    fileprivate struct C {
        struct CellHeight {
            static let close: CGFloat = 144 // equal or greater foregroundView height
            static let open: CGFloat = 400 // equal or greater containerView height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as FoldingCell = tableView.cellForRow(at: indexPath)
            else {
            return
        }
        
        var duration = 0.0
        if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.row] = kOpenCellHeight
            //cell.selectedAnimation(true, animated: true, completion: nil)
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = kCloseCellHeight
            //cell.selectedAnimation(false, animated: true, completion: nil)
            cell.unfold(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { _ in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let cell as FoldingCell = cell {
            cell.backgroundColor = .clear
            if cellHeights[indexPath.row] == C.CellHeight.close {
                //cell.selectedAnimation(false, animated: false, completion:nil)
                cell.unfold(false, animated: false, completion: nil)
            } else {
                //cell.selectedAnimation(true, animated: false, completion: nil)
                cell.unfold(true, animated: false, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let destination = segue.destination as! DetailedEventViewController
            destination.event = sender as? Event
        }
    }
    

    
}
