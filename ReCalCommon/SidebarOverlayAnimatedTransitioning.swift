//
//  SidebarOverlayTransitioning.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class SidebarOverlayAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    }
    func animationEnded(transitionCompleted: Bool) {
    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
}

class SidebarOverlayPresentationAnimatedTransitioning: SidebarOverlayAnimatedTransitioning {
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let presentingVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let presentingView: UIView = presentingVC.view
        let presentedVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let presentedView: UIView! = presentedVC.view
        
        let finalFrame = transitionContext.finalFrameForViewController(presentedVC)
        let initialFrame = CGRect(origin: CGPoint(x: -finalFrame.size.width, y: finalFrame.origin.y), size: finalFrame.size)
        presentedView.frame = initialFrame
        containerView.addSubview(presentedView)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            presentedView.frame = finalFrame
        }) { (completed) -> Void in
            transitionContext.completeTransition(completed)
        }
    }
}

class SidebarOverlayDismissalAnimatedTransitioning: SidebarOverlayAnimatedTransitioning {
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let presentingVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let presentingView: UIView = presentingVC.view
        let presentedVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let presentedView: UIView! = presentedVC.view
        
        let initialFrame = transitionContext.finalFrameForViewController(presentedVC)
        let finalFrame = CGRect(origin: CGPoint(x: -initialFrame.size.width, y: initialFrame.origin.y), size: initialFrame.size)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            presentedView.frame = finalFrame
            }) { (completed) -> Void in
                presentedView.removeFromSuperview()
                transitionContext.completeTransition(completed)
        }
    }
}