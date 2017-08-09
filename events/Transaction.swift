//
//  Transaction.swift
//  events
//
//  Created by Rhian Chavez on 7/11/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation


struct TransactionKey {
    static let id = "id"
    static let receiver = "receiver"
    static let amount = "amount"
    static let date = "date"
    static let status = "status"
    static let name = "name"
}
class Transaction: NSObject {
    var id: String
    var receiver: AppUser
    var amount: Double
    var date: Date
    var status: Bool // true if paid, false if not
    var name: String //name of the associated event
    
    init(dict: [String: Any]) {
        self.id = dict[TransactionKey.id] as! String
        self.receiver = AppUser(dictionary: dict[TransactionKey.receiver] as! [String: Any])
        self.amount = dict[TransactionKey.amount] as! Double
        self.status = dict[TransactionKey.status] as! Bool
        let dateString = dict[TransactionKey.date] as! String
        self.date = Utilities.getDateFromString(dateString: dateString)
        self.name = dict[TransactionKey.name] as! String
    }
    
    init(event: Event) {
        self.id = event.eventid
        self.receiver = event.organizer
        self.amount = event.cost!
        self.date = event.date
        self.status = false
        self.name = event.eventname
    }
    
    func completeTransaction() {
        AppUser.current.wallet = AppUser.current.wallet - self.amount
        FirebaseDatabaseManager.shared.updateWallet(id: AppUser.current.uid, withValue: AppUser.current.wallet, completion: {})
        FirebaseDatabaseManager.shared.updateOtherUserWallet(id: self.receiver.uid, withValue: self.amount)
        FirebaseDatabaseManager.shared.updateTransaction(id: self.id)
    }
    
    func getDictionary() -> [String: Any] {
        let dict: [String: Any] = [TransactionKey.id: self.id,
                    TransactionKey.receiver: self.receiver.getBasicDict(),
                    TransactionKey.amount: self.amount,
                    TransactionKey.date: self.date.description,
                    TransactionKey.status: self.status,
                    TransactionKey.name: self.name]
        return dict
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Transaction {
            return self.id == other.id
        }
        return false
    }
}
