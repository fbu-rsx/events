//
//  detailView3.swift
//  events
//
//  Created by Xiu Chen on 8/4/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class detailView3: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var eventTransactions: [String: Any] = [:]
    
    override func awakeFromNib() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let bundle = Bundle(path: "events/EventsTableViewPage")
        tableView.register(UINib(nibName: "GuestsTableViewCell", bundle: bundle), forCellReuseIdentifier: "userCell")
//        filterTransactions()
    }
    
//    func filterTransactions() {
//        for event in AppUser.current.events {
//            if event.
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuestsTableViewCell", for: indexPath)
        return cell
    }
}
