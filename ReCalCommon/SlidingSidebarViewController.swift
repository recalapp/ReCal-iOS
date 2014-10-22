//
//  SlidingSidebarViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SlidingSidebarViewController: UIViewController, UIScrollViewDelegate {
    
    private var sidebarLeftBuffer: CGFloat {
        return self.view.bounds.size.width
    }
    
    private let sidebarRightBuffer: CGFloat = 20.0
    
    private var sidebarWidth: CGFloat {
        get {
            return self.view.bounds.size.width / 5.0
        }
    }
    
    public var disablesScrollingInPrimaryViewWhenCollapsed = false
    
    private(set) public var sidebarIsShown: Bool = true {
        didSet {
            if self.disablesScrollingInPrimaryViewWhenCollapsed {
                if let scrollView = self.sidebarContainerScrollView {
                    if sidebarIsShown {
                        self.view.addGestureRecognizer(scrollView.panGestureRecognizer)
                    } else {
                        scrollView.addGestureRecognizer(scrollView.panGestureRecognizer)
                    }
                }
            }
        }
    }
    
    private var sidebarContainerScrollView: UIScrollView?
    
    private var sidebarView: UIVisualEffectView?
    
    private(set) public var primaryContentView: UIView?
    
    private(set) public var sidebarContentView: UIView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let contentView = UIView()
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(contentView)
        self.primaryContentView = contentView
        self.view.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(contentView, inParentView: self.view, withInsets: UIEdgeInsetsZero))
        self.setUpSidebar()
    }
    
    private func setUpSidebar() {
        // sidebar view
        let sidebarView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.sidebarView = sidebarView
        
        // sidebar content view
        let sidebarContentView = UIView()
        sidebarContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        sidebarContentView.backgroundColor = UIColor.redColor()
        self.sidebarContentView = sidebarContentView
        self.sidebarView?.contentView.addSubview(sidebarContentView)
        
        // constraints
        sidebarView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(sidebarContentView, inParentView: sidebarView, withInsets: UIEdgeInsets(top: 0, left: self.sidebarLeftBuffer, bottom: 0, right: self.sidebarRightBuffer)))
        
        self.setUpOverlayScrollView()
    }
    
    /// Set up the scroll view for sidebar
    private func setUpOverlayScrollView() {
        // creating and setting constraints
        let scrollView = OverlayScrollView()
        scrollView.delegate = self
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.sidebarContainerScrollView = scrollView
        self.view.addSubview(scrollView)
        self.view.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(scrollView, inParentView: self.view, withInsets: UIEdgeInsetsZero))
        scrollView.contentSize = CGSize(width: self.sidebarWidth + self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.view.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        // adding sidebar
        if let sidebarView = self.sidebarView {
            scrollView.addSubview(sidebarView)
            sidebarView.frame = CGRect(x: -self.sidebarLeftBuffer, y: 0, width: self.sidebarWidth + self.sidebarLeftBuffer + self.sidebarRightBuffer, height: self.view.bounds.size.height)
        }
        
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, var targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // check if we should be hiding the sidebar - if it is more than halfway hidden or if the velocity is positive
        // TODO might be better to not use this at all. can set content offset at will begin decelerating
        if velocity.x > 0 || targetContentOffset.memory.x > self.sidebarWidth/2 {
            targetContentOffset.put(CGPoint(x:self.sidebarWidth, y:0))
            self.sidebarIsShown = false
        } else {
            targetContentOffset.put(CGPointZero)
            self.sidebarIsShown = true
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
