//
//  FadeOverlayAnimatedTransitioning.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

extension FadeOverlayPresentation {
    class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        }
        func animationEnded(transitionCompleted: Bool) {
        }
        func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
            return 0.4
        }
    }
    class PresentationAnimatedTransitioning: AnimatedTransitioning {
        override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView()
            let presentingVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let presentingView: UIView = presentingVC.view
            let presentedVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedView: UIView! = presentedVC.view
            
            let finalFrame = transitionContext.finalFrameForViewController(presentedVC)
            presentedView.frame = finalFrame
            presentedView.alpha = 0
            containerView.addSubview(presentedView)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
                presentedView.alpha = 1
                }) { (completed) -> Void in
                    transitionContext.completeTransition(completed)
            }
        }
    }
    
    class DismissalAnimatedTransitioning: AnimatedTransitioning {
        override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView()
            let presentingVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentingView: UIView = presentingVC.view
            let presentedVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let presentedView: UIView! = presentedVC.view
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
                presentedView.alpha = 0
                }) { (completed) -> Void in
                    presentedView.removeFromSuperview()
                    transitionContext.completeTransition(completed)
            }
        }
    }
}