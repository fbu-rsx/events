//
//  CreateEventPageControllerViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/21/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

protocol CreateEventPageControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter eventPageController: the CreateEventPageController instance
     - parameter count: the total number of pages.
     */
    func eventPageController(_ eventPageController: CreateEventPageController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter eventPageController: the CreateEventPageController instance
     - parameter index: the index of the currently visible page.
     */
    func eventPageController(_ eventPageController: CreateEventPageController,
                                    didUpdatePageIndex index: Int)
    
}

class CreateEventPageController: UIPageViewController {
    
    weak var pageControlDelegate: CreateEventPageControllerDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("CreateTitleViewController"),
                self.newViewController("CreateLocationNavController"),
                self.newViewController("CreateGuestsNavController"),
                self.newViewController("CreateAboutViewController")]
    }()
    
    private func newViewController(_ name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageControlDelegate?.eventPageController(self,
                                                    didUpdatePageCount: orderedViewControllers.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension CreateEventPageController: UIPageViewControllerDataSource {
    
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

extension CreateEventPageController: UIPageViewControllerDelegate {
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
