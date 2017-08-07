//
//  SendBirdViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/4/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import SendBirdSDK

class SendBirdViewController: UIViewController {
    
    var event: Event!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        event = AppUser.current.events[0]
//        SBDMain.add(self, identifier: <#T##String#>)
//        var userIDs = Array(event.guestlist.keys)
//        userIDS.append(event.organizer.uid)
//        
//        SBDGroupChannel.createChannel(withName: event.eventname, isDistinct: true, userIds: userIDs, coverUrl: nil, data: nil, customType: nil) { (chanel: SBDGroupChannel?, error: SBDError?) in
//            if let error = error {
//                print("SENDBIRD group channel error: \(error.localizedDescription)")
//            }
//        }
//        
//        SBDGroupChannel.getWithUrl("", completionHandler: <#T##((SBDGroupChannel?, SBDError?) -> Void)?##((SBDGroupChannel?, SBDError?) -> Void)?##(SBDGroupChannel?, SBDError?) -> Void#>)
       
        let chatView = ChattingView(frame: self.view.frame)
        self.view = chatView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SendBirdViewController: SBDChannelDelegate {
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        // Received a chat message
        
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        // When read receipt has been updated
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        // When typing status has been updated
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        // When a new member joined the group channel
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        // When a member left the group channel
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        // When a new user entered the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        // When a new user left the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        // When a user is muted on the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        // When a user is unmuted on the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        // When a user is banned on the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        // When a user is unbanned on the open channel
    }
    
    func channelWasFrozen(_ sender: SBDOpenChannel) {
        // When the open channel is frozen
    }
    
    func channelWasUnfrozen(_ sender: SBDOpenChannel) {
        // When the open channel is unfrozen
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        // When a channel property has been changed
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        // When a channel has been deleted
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        // When a message has been deleted
    }
}
