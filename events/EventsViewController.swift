//
//  EventsViewController.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import ImagePicker
import OAuthSwift

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, imagePickerDelegate2, UIViewControllerPreviewingDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var cellHeight: CGFloat = 144
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let bundle = Bundle(path: "events/EventsTableViewPage")
        tableView.register(UINib(nibName: "EventsTableViewCell", bundle: bundle), forCellReuseIdentifier: "eventCell")
        tableView.separatorStyle = .none


        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh), name: BashNotifications.refresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh(_:)), name: BashNotifications.delete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh(_:)), name: BashNotifications.invite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh(_:)), name: BashNotifications.accept, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh(_:)), name: BashNotifications.decline, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refresh(_:)), name: BashNotifications.delete, object: nil)
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        OAuthSwiftManager.shared.getSpotifyUserID {
            // Make OAuth take place in webview within our app
            OAuthSwiftManager.shared.oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: OAuthSwiftManager.shared.oauth)
            // setup alert controller
            let alertController = UIAlertController(title: "Spotify Login", message: "Please login to Spotify...", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                OAuthSwiftManager.shared.spotifyLogin(success: nil, failure: { (error) in
                    print(error)
                })
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func refresh(_ notification: Notification) {
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
    
    func presenter(imagePicker : ImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
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
