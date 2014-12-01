//
//  SidebarOverlayTransitioning.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class SidebarOverlayAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    let direction: SidebarOverlayTransitioningDelegate.Direction
    init(direction: SidebarOverlayTransitioningDelegate.Direction) {
        self.direction = direction
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    }
    func animationEnded(transitionCompleted: Bool) {
    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
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
        let originX = self.direction == .Left ? -finalFrame.size.width : containerView.bounds.size.width + finalFrame.size.width
        let initialFrame = CGRect(origin: CGPoint(x: originX, y: finalFrame.origin.y), size: finalFrame.size)
        presentedView.frame = initialFrame
        containerView.addSubview(presentedView)
        presentedVC.viewWillAppear(true)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            presentedView.frame = finalFrame
        }) { (completed) -> Void in
            presentedVC.viewDidAppear(true)
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
        let originX = self.direction == .Left ? -initialFrame.size.width : containerView.bounds.size.width + initialFrame.size.width
        let finalFrame = CGRect(origin: CGPoint(x: originX, y: initialFrame.origin.y), size: initialFrame.size)
        presentedVC.viewWillDisappear(true)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            presentedView.frame = finalFrame
            }) { (completed) -> Void in
                presentedVC.viewDidDisappear(true)
                presentedView.removeFromSuperview()
                transitionContext.completeTransition(completed)
        }
    }
}