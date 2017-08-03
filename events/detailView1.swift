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

class detailView1: UIView, ImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate {
    
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
    
    var event: Event?{
        didSet{
            loadImages()
        }
    }
    
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
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        print(rootViewController)
        rootViewController?.registerForPreviewing(with: self, sourceView: self)
        
//        if( traitCollection.forceTouchCapability == .available){
//            
//            if let navigationController = rootViewController as? UINavigationController {
//                rootViewController = navigationController.viewControllers.first
//            }
//            if let tabBarController = rootViewController as? UITabBarController {
//                rootViewController = tabBarController.selectedViewController
//            }
//            rootViewController?.registerForPreviewing(with: self, sourceView: self)
//            
//        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        rootViewController?.show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let detailVC = DetailMediaViewController(nibName: "DetailMediaViewController", bundle: nil)
        
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return nil }
        
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }

        let photo = photos[indexPath.row]
        
        detailVC.pic = photo

        detailVC.popoverPresentationController?.sourceView = detailVC.view
        detailVC.popoverPresentationController?.sourceRect = CGRect(x: 8, y: 60, width: 359, height: 359)
        //print( detailVC.popoverPresentationController)
        //detailVC.preferredContentSize = CGSize(width: 0.0, height: 200)
        //detailVC.
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    

    
    func loadImages(){
        for imageID in event!.photos.keys{
            FirebaseStorageManager.shared.downloadImage(event: self.event!, imageID: imageID, completion: { (image) in
                if self.photos.contains(image) == false {
                    self.photos.append(image)
                }
                self.collectionView.reloadData()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotos.append(photos[indexPath.row])
        if selectedPhotos.count != 0 {
            button.setTitle("Download", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        selectedPhotos.remove(at: selectedPhotos.index(of: photos[indexPath.row])!)
        if selectedPhotos.count == 0 {
            button.setTitle("Upload", for: .normal)
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
            event?.uploadImage(images[image])
            photos.insert(images[image], at: 0)
        }
        collectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
        //imagePicker. somehow deselect previously selected items
    }
    
    // required function
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        
    }
    
}
