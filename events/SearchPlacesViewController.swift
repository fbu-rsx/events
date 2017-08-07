//
//  SearchPlacesViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/3/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var predictions: [GMSAutocompletePrediction] = []
    var searchController: UISearchController!
    var selectedPrediction: GMSAutocompletePrediction?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
        
        let bundle = Bundle(path: "events/SearchViewControllers")
        tableView.register(UINib(nibName: "SearchPlacesTableViewCell", bundle: bundle), forCellReuseIdentifier: "SearchPlacesTableViewCell")
        
        
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlacesTableViewCell") as! SearchPlacesTableViewCell
        cell.prediction = predictions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SearchPlacesTableViewCell
        selectedPrediction = cell.prediction
        searchController.isActive = false
        searchController.dismiss(animated: true, completion: nil)
    }
}
