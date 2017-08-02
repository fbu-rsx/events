//
//  SerachEventsViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/1/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class SearchEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var filteredEvents: [Event] = []
    var searchController: UISearchController!
    var selectedEvent: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        
        let bundle = Bundle(path: "events/SearchViewControllers")
        tableView.register(UINib(nibName: "SearchEventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "SearchEventsTableViewCell")
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchEventsTableViewCell") as! SearchEventsTableViewCell
        cell.event = filteredEvents[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SearchEventsTableViewCell
        selectedEvent = cell.event
        searchController.isActive = false
        searchController.dismiss(animated: true, completion: nil)
    }
}
