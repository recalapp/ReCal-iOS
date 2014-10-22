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
    
    private(set) public var sidebarIsShown: Bool = true {
        didSet {
            if let scrollView = self.sidebarContainerScrollView {
                if sidebarIsShown {
                    self.view.addGestureRecognizer(scrollView.panGestureRecognizer)
                } else {
                    scrollView.addGestureRecognizer(scrollView.panGestureRecognizer)
                }
            }
        }
    }
    
    private var sidebarContainerScrollView: UIScrollView?
    
    private var sidebarView: UIVisualEffectView?
    
    private(set) public var sidebarContentView: UIView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
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
        let leadingConstraint = NSLayoutConstraint(item: sidebarContentView, attribute: .Leading, relatedBy: .Equal, toItem: sidebarView, attribute: .Left, multiplier: 1, constant: self.sidebarLeftBuffer)
        let widthConstraint = NSLayoutConstraint(item: sidebarContentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.sidebarWidth)
        let topConstraint = NSLayoutConstraint(item: sidebarContentView, attribute: .Top, relatedBy: .Equal, toItem: sidebarView, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: sidebarContentView, attribute: .Bottom, relatedBy: .Equal, toItem: sidebarView, attribute: .Bottom, multiplier: 1, constant: 0)
        sidebarContentView.addConstraint(widthConstraint)
        sidebarView.addConstraints([leadingConstraint, topConstraint, bottomConstraint])
        
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
        let leadingConstraint = NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
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
