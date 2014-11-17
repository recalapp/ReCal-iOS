//
//  SidebarOverlayTransitioningDelegate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SidebarOverlayTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public let direction: Direction
    
    public weak var delegate: SidebarOverlayPresentationDelegate?
    
    public init(direction: Direction) {
        self.direction = direction
        super.init()
    }
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = SidebarOverlayPresentationController(presentedViewController: presented, presentingViewController:presenting)
        presentationController.direction = self.direction
        presentationController.sidebarDelegate = self.delegate
        return presentationController
    }
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = SidebarOverlayPresentationAnimatedTransitioning(direction: self.direction)
        return animationController
    }
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = SidebarOverlayDismissalAnimatedTransitioning(direction: self.direction)
        return animationController
    }
    public enum Direction {
        case Left, Right
    }
}

public protocol SidebarOverlayPresentationDelegate: class {
    func sidebarOverlayPresentation(presentationController: UIPresentationController, didTapOutsidePresentedViewController presentedViewController: UIViewController, presentingViewController: UIViewController)
}