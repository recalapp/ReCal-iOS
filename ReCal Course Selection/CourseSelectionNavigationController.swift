//
//  CourseSelectionNavigationController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/9/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class CourseSelectionNavigationController: AuthenticationNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBarsWhenKeyboardAppears = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let courseSelectionViewController = self.logicalRootViewController as CourseSelectionViewController
        courseSelectionViewController.viewContentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.navigationBar.bounds.size.height - UIApplication.sharedApplication().statusBarFrame.size.height)
    }
    override func viewDidAppear(animated: Bool) {
        let courseSelectionViewController = self.logicalRootViewController as CourseSelectionViewController
        courseSelectionViewController.viewContentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.navigationBar.bounds.size.height - UIApplication.sharedApplication().statusBarFrame.size.height)
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === self.logicalRootViewController {
            println(parentSize)
            return CGSize(width: parentSize.width, height: parentSize.height - self.navigationBar.bounds.size.height - UIApplication.sharedApplication().statusBarFrame.size.height)
        }
        return super.sizeForChildContentContainer(container, withParentContainerSize: parentSize)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
