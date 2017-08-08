//
//  ChatViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/4/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import IQKeyboardManagerSwift
import JSQMessagesViewController
import Photos
import ImagePicker

final class ChatViewController: JSQMessagesViewController {
    
    var event: Event!
    var channelRef: DatabaseReference?
    private var channelRefHandle: DatabaseHandle?
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    
    //see if user is typing
    private lazy var userIsTypingRef: DatabaseReference = self.channelRef!.child("typingIndicator").child(self.senderId) // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    private lazy var usersTypingQuery: DatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    //photos
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://events-86286.appspot.com/")
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: DatabaseHandle?
    
    let picker = ImagePickerController()
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    private var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelRef = Database.database().reference().child("channels/\(event.eventid)")
        senderDisplayName = AppUser.current.name
        senderId = AppUser.current.uid
        
        picker.delegate = self
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded {
            observeMessages()
            loaded = true
        }
        observeTyping()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
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
        let guest = event.appUserGuests[messages[indexPath.item].senderId]!
        let data = try! Data(contentsOf: URL(string: guest.photoURLString)!)
        let image = UIImage(data: data)
        let imageSource = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
        return imageSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return nil
        } else {
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
            
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        //return 17.0
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return 0.0
        } else {
            
            return 17.0
            
        }
    }
    
    
    //Change message buble colors
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: Colors.coral)
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    //creating messages
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        isTyping = false
    }
    
    private func observeMessages() {
        //        self.activityIndicator?.startAnimating()
        messageRef = channelRef!.child("messages")
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 3 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        //        let picker = UIImagePickerController()
        //        picker.delegate = self
        //        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
        //            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //        } else if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
        //            picker.sourceType = UIImagePickerControllerSourceType.camera
        //        }
        
        present(picker, animated: true, completion:nil)
    }
}

extension ChatViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        picker.dismiss(animated: true, completion: nil)
        
        for image in images {
            if let key = sendPhotoMessage() {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = AppUser.current.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
                
            }
        }
        picker.resetAssets()
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    }
}

//// MARK: Image Picker Delegate
//extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        picker.dismiss(animated: true, completion:nil)
//
//        // 1
//        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
//            // Handle picking a Photo from the Photo Library
//            // 2
//            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
//            let asset = assets.firstObject
//
//            // 3
//            if let key = sendPhotoMessage() {
//                // 4
//                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//                    let imageFileURL = contentEditingInput?.fullSizeImageURL
//                    let data = try! Data(contentsOf: imageFileURL!)
//
//                    // 5
//                    let path = "\(AppUser.current.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
//
//                    // 6
//                    self.storageRef.child(path).putData(data, metadata: nil) { (metadata, error) in
//                        if let error = error {
//                            print("Error uploading photo: \(error.localizedDescription)")
//                            return
//                        }
//                        // 7
//                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
//                    }
//                })
//            }
//        } else {
//            // Handle picking a Photo from the Camera - TODO
//            // 1
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            // 2
//            if let key = sendPhotoMessage() {
//                // 3
//                let imageData = UIImageJPEGRepresentation(image, 1.0)
//                // 4
//                let imagePath = AppUser.current.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
//                // 5
//                let metadata = StorageMetadata()
//                metadata.contentType = "image/jpeg"
//                // 6
//                storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
//                    if let error = error {
//                        print("Error uploading photo: \(error)")
//                        return
//                    }
//                    // 7
//                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
//                }
//            }
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion:nil)
//    }
//}
