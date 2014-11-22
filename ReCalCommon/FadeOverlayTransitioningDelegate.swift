//
//  FadeOverlayTransitioningDelegate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
public class FadeOverlayPresentation {
    public class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
        public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
            let presentationController = PresentationController(presentedViewController: presented, presentingViewController:presenting)
            return presentationController
        }
        public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            let animationController = PresentationAnimatedTransitioning()
            return animationController
        }
        public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            let animationController = DismissalAnimatedTransitioning()
            return animationController
        }
    }
}
