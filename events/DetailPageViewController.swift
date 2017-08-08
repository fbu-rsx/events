//
//  DetailPageViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/7/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

protocol DetailPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter eventPageController: the DetailPageViewController instance
     - parameter count: the total number of pages.
     */
    func eventPageController(_ eventPageController: DetailPageViewController,
                             didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter eventPageController: the DetailPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func eventPageController(_ eventPageController: DetailPageViewController,
                             didUpdatePageIndex index: Int)
    
}


class DetailPageViewController: UIPageViewController {
    
    weak var pageControlDelegate: DetailPageViewControllerDelegate?
    
    weak var event: Event?
    
    var imageDelegate: imagePickerDelegate2?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("detailView0"),
                self.newViewController("detailView1"),
                self.newViewController("ChatViewController"),
                self.newViewController("detailView2")]
    }()
    
    private func newViewController(_ name: String) -> UIViewController {
        let frame = self.view.frame
        
        if name == "ChatViewController" {
            let bundle = Bundle(path: "events/Chat")
            let vc =  ChatViewController(nibName: "ChatViewController", bundle: nil)
            vc.event = self.event!
            return vc
        } else {
            let nib = UINib(nibName: name, bundle: nil)
            var newView: UIView!
            switch name {
            case "detailView0":
                let temp = nib.instantiate(withOwner: self, options: nil).first as! detailView0
                temp.event = event
                newView = temp
            case "detailView1":
                let temp = nib.instantiate(withOwner: self, options: nil).first as! detailView1
                temp.event = event
                temp.delegate = imageDelegate
                newView = temp
            case "detailView2":
                let temp = nib.instantiate(withOwner: self, options: nil).first as! detailView2
                temp.event = event
                newView = temp
            default:
                print("ERROR: NO VIEW INSTANTIATED")
            }
            newView.frame = frame
            
            let vc = UIViewController()
            vc.view = newView
            return vc
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(DetailPageViewController.enableSwipe(_:)), name: BashNotifications.accept, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailPageViewController.disableSwipe(_:)), name: BashNotifications.decline, object: nil)

        self.delegate = self
        
        if event?.myStatus == .accepted {
            self.dataSource = self
        } else {
            self.dataSource = nil
        }
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageControlDelegate?.eventPageController(self,
                                                 didUpdatePageCount: orderedViewControllers.count)
    }
    
    func enableSwipe(_ notification: NSNotification) {
        let acceptedEvent = notification.object as! Event
        if acceptedEvent.eventid == event?.eventid {
            self.dataSource = self
        }
    }
    
    func disableSwipe(_ notification: NSNotification) {
        let declinedEvent = notification.object as! Event
        if declinedEvent.eventid == event?.eventid {
            if let firstViewController = orderedViewControllers.first {
                setViewControllers([firstViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
            self.dataSource = nil
        }
    }
    
    
    
    override var previewActionItems: [UIPreviewActionItem] {
        let acceptAction = UIPreviewAction(title: "Accept", style: .default) { (action, viewController) -> Void in
            // do stuff that accepts event invite
        }
        
        let declineAction = UIPreviewAction(title: "Decline", style: .destructive) { (action, viewController) -> Void in
            // do stuff the declines event invite
        }
        if event?.organizer.uid == AppUser.current.uid{
            return []
        }
        return [acceptAction, declineAction]
    }
    
}

extension DetailPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let count = orderedViewControllers.count
        
        guard count > nextIndex else { return nil }
        
        
        return orderedViewControllers[nextIndex]
    }
}

extension DetailPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            pageControlDelegate?.eventPageController(self,
                                                     didUpdatePageIndex: index)
        }
    }
}


