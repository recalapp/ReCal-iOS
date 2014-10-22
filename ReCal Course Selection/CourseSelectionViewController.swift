//
//  CourseSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

let courseSearchViewControllerStoryboardId = "CourseSearch"

class CourseSelectionViewController: SlidingSidebarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let courseSearchViewController = self.storyboard?.instantiateViewControllerWithIdentifier(courseSearchViewControllerStoryboardId) as CourseSearchTableViewController
        courseSearchViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addChildViewController(courseSearchViewController)
        self.sidebarContentView?.addSubview(courseSearchViewController.view)
        self.sidebarContentView?.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(courseSearchViewController.view, inParentView: self.sidebarContentView!, withInsets: UIEdgeInsetsZero))
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
