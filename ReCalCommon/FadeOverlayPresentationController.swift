//
//  FadeOverlayPresentationController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/22/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

extension FadeOverlayPresentation {
    class PresentationController: UIPresentationController {
        
        override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
            return parentSize
        }
        override func frameOfPresentedViewInContainerView() -> CGRect {
            let size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: self.containerView.bounds.size)
            return CGRect(origin: CGPointZero, size: size)
        }
        override func containerViewWillLayoutSubviews() {
            // for rotation
            self.presentedView().frame = self.frameOfPresentedViewInContainerView()
        }
        override func adaptivePresentationStyle() -> UIModalPresentationStyle {
            return UIModalPresentationStyle.Custom
        }
    }
}
