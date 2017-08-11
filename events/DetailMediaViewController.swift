//
//  DetailMediaViewController.swift
//  events
//
//  Created by Rhian Chavez on 8/2/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage

protocol deleteImageDelegate {
    func deleteImage(imageID: String)
}

class DetailMediaViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    var pic: UIImage?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var profileImageURLString: String?
    var event: Event?
    var imageID: String?
    var delegate: deleteImageDelegate?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.layer.cornerRadius = 5
        deleteButton.backgroundColor = UIColor(hexString: "#95a5a6")
        downloadButton.layer.cornerRadius = 5
        downloadButton.backgroundColor = Colors.coral
        image.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        image.image = pic
        // Do any additional setup after loading the view.
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
        profileImageView.af_setImage(withURL: URL(string: profileImageURLString!)!)
        nameLabel.text = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var previewActionItems: [UIPreviewActionItem]{
        let likeAction = UIPreviewAction(title: "Download", style: .default) { (action, viewController) -> Void in
            UIImageWriteToSavedPhotosAlbum(self.pic!, nil, nil, nil)
        }
        
        let deleteAction = UIPreviewAction(title: "Delete", style: .destructive) { (action, viewController) -> Void in
            print("You deleted the photo")
            FirebaseStorageManager.shared.deleteImage(event: self.event!, imageID: self.imageID!)
            self.delegate?.deleteImage(imageID: self.imageID!)
        }
        
        return [likeAction, deleteAction]
    }

    @IBAction func onDelete(_ sender: Any) {
         FirebaseStorageManager.shared.deleteImage(event: self.event!, imageID: self.imageID!)
        self.delegate?.deleteImage(imageID: self.imageID!)
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func onDownload(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.pic!, nil, nil, nil)
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
