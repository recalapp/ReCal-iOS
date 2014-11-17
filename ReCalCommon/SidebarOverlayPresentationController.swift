//
//  SidebarOverlayPresentationController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class SidebarOverlayPresentationController: UIPresentationController {
    lazy private var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.alpha = 0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDimmingViewTap:")
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass) {
        case (.Regular, _), (.Unspecified, _), (.Compact, .Compact):
            return CGSize(width: floor(parentSize.width/3), height: parentSize.height)
        case (.Compact, .Regular), (.Compact, .Unspecified):
            return CGSize(width: floor(parentSize.width/1.5), height: parentSize.height)
        }
    }
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: self.containerView.bounds.size)
        return CGRect(origin: CGPoint(x: 0, y: 0), size: size)
    }
    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = self.containerView.bounds
        self.presentedView().frame = self.frameOfPresentedViewInContainerView()
    }
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.Custom
    }
    override func presentationTransitionWillBegin() {
        self.dimmingView.frame = self.containerView.bounds
        self.containerView.addSubview(self.dimmingView)
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 1
                }, completion: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
                
            })
        } else {
            self.dimmingView.alpha = 1.0
        }
    }
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 0
                }, completion: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.dimmingView.removeFromSuperview()
            })
        } else {
            self.dimmingView.alpha = 0
            self.dimmingView.removeFromSuperview()
        }
    }
    
    func handleDimmingViewTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .Ended {
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
