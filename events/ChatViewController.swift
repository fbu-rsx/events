//
//  ChatViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/4/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FirebaseDatabase
import IQKeyboardManagerSwift
import JSQMessagesViewController

final class ChatViewController: JSQMessagesViewController {
    
    var event: Event!
    var channelRef: DatabaseReference?
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelRef = FirebaseDatabaseManager.shared.ref.child("channels/\(event.eventid)")
        title = event.eventname
        senderDisplayName = AppUser.current.name
        senderId = AppUser.current.uid
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 10, height: 10)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 10, height: 10)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    
    //Change message buble colors
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
}
