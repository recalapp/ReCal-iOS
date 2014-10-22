//
//  OverlayScrollView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class OverlayScrollView: UIScrollView {

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, withEvent: event)
        if hit == self {
            return nil
        }
        return hit
    }

}
