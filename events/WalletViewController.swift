//
//  WalletViewController.swift
//  events
//
//  Created by Xiu Chen on 7/25/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage
import XLPagerTabStrip

class WalletViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Registering the cell xib file with tableview
        let bundle = Bundle(path: "/Users/xiuchen/Desktop/events/events/PaymentTableViewCell.swift")
        let nib = UINib(nibName: "PaymentTableViewCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "PaymentCell")
        
        tableView.allowsSelection = false
        tableView.separatorColor = Colors.coral
//        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.walletChanged(_:)), name: BashNotifications.walletChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
//    func walletChanged(_ notification: NSNotification) {
//        let value = notification.object as! Double
//        walletAmount.text = String(format: "%.2f", value)
//    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppUser.current.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentTableViewCell
        cell.transaction = AppUser.current.transactions[indexPath.row]
        return cell
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        //return IndicatorInfo(title: "Wallet", image: UIImage(named: "wallet"))
        return IndicatorInfo(title: "Wallet")
    }


}
