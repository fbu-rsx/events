//
//  DetailedEventViewController.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import ImagePicker
import MapKit

class DetailedEventViewController: UIViewController, ImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
/*var eventid: String
 var eventname: String
 var totalcost: Double? //optional because may just be a free event
 var location: [Double]
 var organizerID: String //uid of the organizer
 var guestlist: [String: Bool]
 var photos: [String: String]
 var eventDictionary: [String: Any]*/
    
    var images: [UIImage] = []
 
    var event: Event? {
        didSet {
            centerImage.layer.cornerRadius = 0.5*centerImage.frame.width
            centerImage.layer.masksToBounds = true
            mapView.setCenter(event!.coordinate, animated: true)
            //centerImage.image = event?.organizerID
            let user = FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizerID)!)
            // set orgainzer pic
            let url = URL(string: user.photoURLString)
            centerImage.af_setImage(withURL: url!)
            // set organizerlabel as well
            organizerLabel.text = user.name
            for imageID in (event?.photos.keys)!{
                FirebaseStorageManager.shared.downloadImage(event: self.event!, imageID: imageID, completion: { (image) in
                    self.images.append(image)
                })
            }
        }
    }
    
    let imagePickerController = ImagePickerController()
    
    //var invited: [] =

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePickerController.delegate = self
        tableView.delegate = self
        collectionView.delegate = self
        
        let bundle = Bundle(path: "/Users/rhianchavez11/Documents/events/events/Views")
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "customImageCell")
        tableView.register(UINib(nibName: "userTableViewCell", bundle: bundle), forCellReuseIdentifier: "userCell")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upload(_ sender: UIButton) {
        present(imagePickerController, animated: true, completion: nil)
    }

    // required function
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        for image in stride(from: 0, to: images.count, by: 1){
            event?.uploadImage(images[image])
        }
        imagePickerController.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    // required function
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        // need to customize cell but can't until Event class updated
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (event?.guestlist.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
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
