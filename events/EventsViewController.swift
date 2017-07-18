//
//  EventsViewController.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FirebaseDatabaseUI

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var myEvents: [Event] = []
    var upcoming: [Event] = []
    var past: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        let bundle = Bundle(path: "/Users/rhianchavez11/Documents/events/events/Views")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "eventCell")
        
        // populate Event lists for tableView data
        print(AppUser.current)
        print(AppUser.current.events)
        for event in AppUser.current.events{
            if event.organizerID == AppUser.current.uid{
                myEvents.append(event)
            }
            let comparison = event.time < Date.init()
            if comparison == true{
                past.append(event)
            }
            else{
                upcoming.append(event)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return cell to present associated with user's events 
        // which data to display is dependent on selected index of segmented control
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsTableViewCell
        // see which data to display
        if segmentedControl.selectedSegmentIndex == 0{
            cell.event = myEvents[indexPath.row]
            return cell
        }
        else if segmentedControl.selectedSegmentIndex == 1{
            cell.event = upcoming[indexPath.row]
            return cell
        }
        else{
            cell.event = past[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of events associated with user in current section
        // number will be dependent on selected index of segmented control
        if segmentedControl.selectedSegmentIndex == 0{
            return myEvents.count
        }
        else if segmentedControl.selectedSegmentIndex == 1{
            return upcoming.count
        }
        else{
            return past.count
        }
    }

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        code
    }
    */
}
