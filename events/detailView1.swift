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

class detailView1: UIView, ImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let picker = ImagePickerController()
    
    var delegate: imagePickerDelegate2?{
        didSet{
            picker.delegate = self
        }
    }

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewCell: UICollectionViewCell!
    
    var photos: [UIImage] = []
    /*
    var event: Event?{
        didSet{
            for imageID in event!.photos.keys{
                FirebaseStorageManager.shared.downloadImage(event: self.event!, imageID: imageID, completion: { (image) in
                    self.photos.append(image)
                })
            }
        }
    }*/
    
    
    
    @IBAction func upload(_ sender: UIButton) {
        delegate?.presenter(imagePicker: picker)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return photos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        return collectionViewCell
    }
    
    // required function
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        //for image in stride(from: 0, to: images.count, by: 1){
            //event?.uploadImage(images[image])
        //}
        print("got here")
        imagePicker.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    // required function
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        
    }
}
