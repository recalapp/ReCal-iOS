//
//  SlidingSidebarViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SlidingSidebarViewController: UIViewController {
    
    private var sidebarWidth: CGFloat {
        get {
            return self.view.bounds.size.width / 5.0
        }
    }
    
    private var sidebarView: UIView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let sidebarView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.sidebarView = sidebarView
        self.setUpOverlayScrollView()
    }
    
    /// Set up the scroll view for sidebar
    private func setUpOverlayScrollView() {
        // creating and setting constraints
        let scrollView = OverlayScrollView()
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
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
            sidebarView.frame = CGRect(x: 0, y: 0, width: self.sidebarWidth, height: self.view.bounds.size.height)
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
