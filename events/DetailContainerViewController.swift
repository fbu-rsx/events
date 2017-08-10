//
//  DetailContainerViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/7/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class DetailContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var pageControl = UIPageControl()
    
    weak var event: Event?
    var imageDelegate: imagePickerDelegate2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = false
        self.pageControl.currentPageIndicatorTintColor = UIColor(hexString: "4CB6BE")
        self.pageControl.pageIndicatorTintColor = UIColor(hexString: "F2F2F2")
        NotificationCenter.default.addObserver(self, selector: #selector(DetailContainerViewController.enablePageControl(_:)), name: BashNotifications.acceptOnDetailContainer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailContainerViewController.disablePageControl(_:)), name: BashNotifications.declineOnDetailContainer, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageControl.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailPageViewController {
            viewController.pageControlDelegate = self
            viewController.event = self.event
            viewController.imageDelegate = self.imageDelegate
            viewController.width = Int(self.view.frame.width)
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem]{
        if event!.organizer.uid == AppUser.current.uid{
            let deleteAction = UIPreviewAction(title: "Delete", style: .destructive) { (action, viewController) -> Void in
                AppUser.current.delete(event: self.event!)
                NotificationCenter.default.post(name: BashNotifications.delete, object: self.event!)
            }
            return [deleteAction]
        }
        
        var actions = [UIPreviewAction]()
     
        let acceptAction = UIPreviewAction(title: "Accept", style: .default) { (action, viewController) -> Void in
            AppUser.current.accept(event: self.event!)
            NotificationCenter.default.post(name: BashNotifications.accept, object: self.event!)

        }
        
        let declineAction = UIPreviewAction(title: "Decline", style: .destructive) { (action, viewController) -> Void in
            AppUser.current.decline(event: self.event!)
            NotificationCenter.default.post(name: BashNotifications.decline, object: self.event!)
        }
        switch event!.myStatus {
            
        case .accepted:
            actions.append(declineAction)
        case .declined:
            actions.append(acceptAction)
        case .noResponse:
            actions.append(acceptAction)
            actions.append(declineAction)
        }
    
        return actions
    }
    
    func addPageControl() {
        if event?.myStatus == .accepted {
            pageControl.frame.origin = CGPoint(x: self.view.center.x - 0.5*pageControl.frame.width, y: 40)
            let window = UIApplication.shared.keyWindow
            window?.addSubview(pageControl)
        }
    }
    
    func showPageControl() {
        pageControl.isHidden = false
    }
    
    func enablePageControl(_ notification: NSNotification) {
        addPageControl()
        showPageControl()
    }
    
    func disablePageControl(_ notification: NSNotification) {
        pageControl.isHidden = true
        pageControl.removeFromSuperview()
    }
}

extension DetailContainerViewController: DetailPageViewControllerDelegate {
    
    func eventPageController(_ eventPageController: DetailPageViewController,
                             didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func eventPageController(_ eventPageController: DetailPageViewController,
                             didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
