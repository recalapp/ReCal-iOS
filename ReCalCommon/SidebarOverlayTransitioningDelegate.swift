//
//  SidebarOverlayTransitioningDelegate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SidebarOverlayTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return SidebarOverlayPresentationController(presentedViewController: presented, presentingViewController:presenting)
    }
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = SidebarOverlayPresentationAnimatedTransitioning()
        return animationController
    }
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = SidebarOverlayDismissalAnimatedTransitioning()
        return animationController
    }
    
}
