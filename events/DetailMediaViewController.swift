//
//  DetailMediaViewController.swift
//  events
//
//  Created by Rhian Chavez on 8/2/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

protocol deleteImageDelegate {
    func deleteImage(imageID: String)
}

class DetailMediaViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    var pic: UIImage?
    
    var event: Event?
    var imageID: String?
    var delegate: deleteImageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = pic
        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
