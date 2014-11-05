//
//  DoubleSidebarScrollView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class DoubleSidebarScrollView: OverlayScrollView {
    
    /// The width of the sidebars
    var sidebarWidthType: DoubleSidebarWidthType = .Proportional(1.0/5.0) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var sidebarWidth: CGFloat {
        switch self.sidebarWidthType {
        case .Proportional(let ratio):
            return self.bounds.size.width * ratio
        case .Exact(let width):
            return width
        }
    }
    
    private var primaryViewWidth: CGFloat {
        return self.bounds.size.width - self.sidebarWidth
    }
    
    /// The view containing the entire sidebar views
    lazy private(set) internal var leftSidebarView: UIView = {
        let sidebarView = UIView()
        sidebarView.backgroundColor = UIColor.redColor()
        self.addSubview(sidebarView)
        return sidebarView
    }()
    lazy private(set) internal var rightSidebarView: UIView = {
        let sidebarView = UIView()
        sidebarView.backgroundColor = UIColor.redColor()
        self.addSubview(sidebarView)
        return sidebarView
    }()
    
    /// The logical primary content view exposed to subclass. Add subviews here
    lazy private(set) internal var primaryView: UIView = {
        let primaryView = UIView()
        self.addSubview(primaryView)
        return primaryView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentSize = CGSize(width: self.sidebarWidth + self.bounds.size.width, height: self.bounds.size.height)
        self.leftSidebarView.frame = CGRect(origin: CGPointZero, size: CGSize(width: self.sidebarWidth, height: self.bounds.size.height))
        self.rightSidebarView.frame = CGRect(origin: CGPoint(x: self.bounds.size.width - self.sidebarWidth, y: 0), size: CGSize(width: self.sidebarWidth, height: self.bounds.size.height))
        self.primaryView.frame = CGRect(origin: CGPoint(x: self.sidebarWidth, y: 0), size: CGSize(width: self.primaryViewWidth, height: self.bounds.size.height))
    }
}

enum DoubleSidebarWidthType {
    case Exact(CGFloat)
    case Proportional(CGFloat)
}