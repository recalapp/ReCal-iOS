//
//  CourseSelectionContainerViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

let courseSelectionViewControllerStoryboardId = "CourseSelection"
let courseSelectionEmbedSegueId = "CourseSelectionEmbed"

class CourseSelectionContainerViewController: UIViewController {

    
    private var courseSelectionViewController: CourseSelectionViewController!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.courseSelectionViewController.viewContentSize = self.contentView.bounds.size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Content Container
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === self.courseSelectionViewController {
            return self.contentView.bounds.size
        }
        return super.sizeForChildContentContainer(container, withParentContainerSize: parentSize)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == courseSelectionEmbedSegueId {
            self.courseSelectionViewController = segue.destinationViewController as CourseSelectionViewController
            
        }
    }
    

}
