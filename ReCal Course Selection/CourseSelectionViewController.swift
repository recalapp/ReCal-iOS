//
//  CourseSelectionViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let courseSearchViewControllerStoryboardId = "CourseSearch"
private let sectionSelectionViewControllerStoryboardId = "SectionSelection"

class CourseSelectionViewController: SlidingSidebarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let courseSearchViewController = self.storyboard?.instantiateViewControllerWithIdentifier(courseSearchViewControllerStoryboardId) as CourseSearchTableViewController
        courseSearchViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addChildViewController(courseSearchViewController)
        self.sidebarContentView.addSubview(courseSearchViewController.view)
        self.sidebarContentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(courseSearchViewController.view, inParentView: self.sidebarContentView, withInsets: UIEdgeInsetsZero))
        let sectionSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier(sectionSelectionViewControllerStoryboardId) as SectionSelectionViewController
        self.addChildViewController(sectionSelectionViewController)
        sectionSelectionViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.primaryContentView.addSubview(sectionSelectionViewController.view)
        self.primaryContentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(sectionSelectionViewController.view, inParentView: self.primaryContentView, withInsets: UIEdgeInsetsZero))
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
