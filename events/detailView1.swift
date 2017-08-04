//
//  detailView1.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import ImagePicker

protocol imagePickerDelegate2 {
    func presenter(imagePicker: ImagePickerController)
    
    //func done(imagePicker: ImagePickerController, )
}

class detailView1: UIView, ImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate, deleteImageDelegate{
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var button: UIButton!

    let picker = ImagePickerController()
    
    var delegate: imagePickerDelegate2?{
        didSet{
            picker.delegate = self
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos: [UIImage] = []
    
    var selectedPhotos: [UIImage] = []
    
    var photoUIDS: [String] = []
    
    var users: [AppUser] = []
    
    var event: Event?{
        didSet{
            loadImages()
        }
    }
    
    // Need to associate each image with an app user upon insertion to the dictionary
    
    var rootViewController = UIApplication.shared.keyWindow?.rootViewController
    
    override func awakeFromNib() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let nib = UINib(nibName: "imageCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "imageCell")
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.width/3, height: self.frame.width/3)
        layout.sectionInset.left = 0
        layout.sectionInset.right = 0
        layout.sectionInset.bottom = 0
        layout.sectionInset.top = 0
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.allowsMultipleSelection = true
        
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }

    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        rootViewController?.show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailMedia") as! DetailMediaViewController
        
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return nil }
        
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }

        let photo = photos[indexPath.row]
        
        detailVC.pic = photo
        
        detailVC.event = event
        
        detailVC.imageID = photoUIDS[indexPath.row]
        
        let user = users[indexPath.row]
        
        detailVC.profileImageURLString = user.photoURLString
        
        detailVC.delegate = self
        
        detailVC.name = user.name

        detailVC.preferredContentSize = CGSize(width: 0.0, height: 375)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    
    func loadImages(){
        for imageID in event!.photos.keys{
            if self.photoUIDS.contains(imageID) == false{
                FirebaseStorageManager.shared.downloadImage(event: self.event!, imageID: imageID, completion: { (image, imageID) in
                    self.photos.append(image)
                    self.photoUIDS.append(imageID)
                    FirebaseDatabaseManager.shared.pullImageData(eventID: (self.event?.eventid)!, imageID: imageID, completion: { (user) in
                        self.users.append(user)
                    })
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    func deleteImage(imageID: String) {
        let index = photoUIDS.index(of: imageID)
        photos.remove(at: index!)
        photoUIDS.remove(at: index!)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotos.append(photos[indexPath.row])
        if selectedPhotos.count != 0 {
            button.setTitle("Download", for: .normal)
            button.backgroundColor = Colors.greenAccepted
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        selectedPhotos.remove(at: selectedPhotos.index(of: photos[indexPath.row])!)
        if selectedPhotos.count == 0 {
            button.setTitle("Upload", for: .normal)
            button.backgroundColor = Colors.coral
        }
        return true
    }
    
    @IBAction func upload(_ sender: UIButton) {
        if selectedPhotos.count == 0{
            delegate?.presenter(imagePicker: picker)
        }
        else{
            for image in selectedPhotos{
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            for index in collectionView.indexPathsForSelectedItems!{
                collectionView.deselectItem(at: index, animated: true)
            }
            button.setTitle("Upload", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return photos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCollectionViewCell
        cell.image.image = photos[indexPath.row]
        rootViewController?.registerForPreviewing(with: self, sourceView: cell.contentView)
        return cell
    }
    
    // required function
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        for image in stride(from: 0, to: images.count, by: 1){
            event?.uploadImage(images[image], completion: {id in
                self.photoUIDS.insert(id, at: 0)
            })
            photos.insert(images[image], at: 0)
            users.insert(AppUser.current, at: 0)
            
        }
        collectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
        //imagePicker. somehow deselect previously selected items
    }
    
    // required function
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        
    }
    
}
