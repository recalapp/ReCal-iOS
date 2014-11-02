//
//  DoubleSidebarViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/31/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let animationSpeed: NSTimeInterval = 0.5
private let sidebarCoverBlurEffectStyle: UIBlurEffectStyle = .Dark

private func breakCharacters(string: String) -> String {
    if string == "" {
        return string
    }
    var newString = ""
    for s in string {
        newString += "\(s)\n"
    }
    return newString.substringToIndex(newString.endIndex.predecessor())
}


// MARK: - Double Sidebar View Controller
public class DoubleSidebarViewController: UIViewController, UIScrollViewDelegate {

    // Mark: Variables
    /// The padding between the sidebar and the space outside of the view (so for the left sidebar, it's the left padding)
    private var sidebarOuterPadding: CGFloat {
        return self.view.bounds.size.width
    }
    
    /// The padding between the sidebars and the primary view
    private let sidebarInnerPadding: CGFloat = 0.0
    
    /// The width of the sidebars
    public var sidebarWidth: CGFloat {
        get {
            return self.view.bounds.size.width / 5.0
        }
    }
    
    /// The scrollview containing the sidebars
    private var sidebarContainerScrollView: UIScrollView!
    
    /// The view containing the entire sidebar views
    private var leftSidebarView: UIView!
    private var rightSidebarView: UIView!
    
    /// The gesture recognizers for sidebar views
    private var leftSidebarTapGestureRecognizer: UITapGestureRecognizer!
    private var rightSidebarTapGestureRecognizer: UITapGestureRecognizer!
    
    /// The views that cover the sidebars when they are not selected
    private var leftSidebarCoverView: UIVisualEffectView!
    private var rightSidebarCoverView: UIVisualEffectView!
    
    /// The text to be put on the cover view
    public var leftSidebarCoverText: String = "" {
        didSet {
            if oldValue != leftSidebarCoverText {
                leftSidebarCoverLabel.text = breakCharacters(leftSidebarCoverText)
            }
        }
    }
    public var rightSidebarCoverText: String = "" {
        didSet {
            if oldValue != rightSidebarCoverText {
                rightSidebarCoverLabel.text = breakCharacters(rightSidebarCoverText)
            }
        }
    }
    
    /// The labels to hold the cover text
    private var leftSidebarCoverLabel: UILabel!
    private var rightSidebarCoverLabel: UILabel!
    
    /// The logical primary content view exposed to subclass. Add subviews here
    private(set) public var primaryContentView: UIView!
    
    /// The logical sidebar content view exposed to subclass. Add subviews here
    private(set) public var leftSidebarContentView: UIView!
    private(set) public var rightSidebarContentView: UIView!
    
    /// The state of the sidebars
    private var sidebarState: DoubleSidebarState = .Unselected {
        didSet {
            if oldValue != sidebarState {
                var translation: CGAffineTransform
                var leftCoverHidden: Bool
                var rightCoverHidden: Bool
                switch sidebarState {
                case .Unselected:
                    translation = CGAffineTransformIdentity
                    leftCoverHidden = false
                    rightCoverHidden = false
                case .LeftSidebarShown:
                    translation = CGAffineTransformMakeTranslation(self.sidebarWidth/2, 0)
                    leftCoverHidden = true
                    rightCoverHidden = false
                case .RightSidebarShown:
                    translation = CGAffineTransformMakeTranslation(-self.sidebarWidth/2, 0)
                    leftCoverHidden = false
                    rightCoverHidden = true
                }
                self.leftSidebarCoverView.hidden = false
                self.rightSidebarCoverView.hidden = false
                UIView.animateWithDuration(animationSpeed, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    self.primaryContentView.transform = translation
                    self.leftSidebarCoverView.alpha = leftCoverHidden ? 0.0 : 1.0
                    self.rightSidebarCoverView.alpha = rightCoverHidden ? 0.0 : 1.0
                    }, completion: { (completed) -> Void in
                        self.leftSidebarCoverView.hidden = completed && leftCoverHidden
                        self.rightSidebarCoverView.hidden = completed && rightCoverHidden
                })
                self.updateSidebarUserInteraction()
                self.leftSidebarTapGestureRecognizer.enabled = sidebarState == .Unselected
                self.rightSidebarTapGestureRecognizer.enabled = sidebarState == .Unselected
            }
        }
    }
    
    /// What the content offset should be for the current state
    private var calculatedContentOffset: CGPoint {
        return self.contentOffsetForDoubleSidebarState(self.sidebarState)
    }
    
    // MARK: Methods
    
    /// Calculate the content offset for the given state
    private func contentOffsetForDoubleSidebarState(state: DoubleSidebarState) -> CGPoint {
        var x: CGFloat
        switch state {
        case .Unselected:
            x = self.sidebarWidth/2.0
        case .LeftSidebarShown:
            x = 0
        case .RightSidebarShown:
            x = self.sidebarWidth
        }
        return CGPoint(x: x, y: 0)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let contentView = UIView()
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(contentView)
        self.primaryContentView = contentView
        self.view.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(contentView, inParentView: self.view, withInsets: UIEdgeInsets(top: 0, left: self.sidebarWidth/2, bottom: 0, right: self.sidebarWidth/2)))
        self.setUpSidebar()
        self.updateSidebarUserInteraction()
    }
    
    private func setUpSidebar() {
        // sidebar view
        self.leftSidebarView = UIView()
        // TODO autoresizing mask?
        self.rightSidebarView = UIView()
        
        // sidebar content view
        self.leftSidebarContentView = UIView()
        self.leftSidebarContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.rightSidebarContentView = UIView()
        self.rightSidebarContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.leftSidebarView.addSubview(self.leftSidebarContentView)
        self.rightSidebarView.addSubview(self.rightSidebarContentView)
        
        // constraints
        self.leftSidebarView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(self.leftSidebarContentView, inParentView: self.leftSidebarView, withInsets: UIEdgeInsets(top: 0, left: self.sidebarOuterPadding, bottom: 0, right: self.sidebarInnerPadding)))
        
        self.rightSidebarView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(self.rightSidebarContentView, inParentView: self.rightSidebarView, withInsets: UIEdgeInsets(top: 0, left: self.sidebarInnerPadding, bottom: 0, right: self.sidebarOuterPadding)))
        
        // add the covers
        let leftBlurEffect = UIBlurEffect(style: sidebarCoverBlurEffectStyle)
        let rightBlurEffect = UIBlurEffect(style: sidebarCoverBlurEffectStyle)
        self.leftSidebarCoverView = UIVisualEffectView(effect: leftBlurEffect)
        self.leftSidebarCoverView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.leftSidebarCoverView.userInteractionEnabled = false
        self.leftSidebarView.addSubview(self.leftSidebarCoverView)
        self.leftSidebarView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(self.leftSidebarCoverView, inParentView: self.leftSidebarView, withInsets: UIEdgeInsetsZero))
        self.rightSidebarCoverView = UIVisualEffectView(effect: rightBlurEffect)
        self.rightSidebarCoverView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.rightSidebarCoverView.userInteractionEnabled = false
        self.rightSidebarView.addSubview(self.rightSidebarCoverView)
        self.rightSidebarView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(self.rightSidebarCoverView, inParentView: self.rightSidebarView, withInsets: UIEdgeInsetsZero))
        
        // add cover labels
        let addCoverLabelForView: (UILabel, UIVisualEffectView, Bool)->Void = { (label, coverView, isLeft) in
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(UIFont.labelFontSize()*1.5)
            label.lineBreakMode = .ByCharWrapping
            label.numberOfLines = 0
            let leftVibrancyEffect = UIVibrancyEffect(forBlurEffect: coverView.effect as UIBlurEffect)
            let leftVibrancyEffectView = UIVisualEffectView(effect: leftVibrancyEffect)
            leftVibrancyEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            leftVibrancyEffectView.contentView.addSubview(label)
            leftVibrancyEffectView.contentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(label, inParentView: leftVibrancyEffectView.contentView, withInsets: UIEdgeInsetsZero))
            coverView.contentView.addSubview(leftVibrancyEffectView)
            coverView.contentView.addConstraints(NSLayoutConstraint.layoutConstraintsForChildView(leftVibrancyEffectView, inParentView: coverView.contentView, withInsets: UIEdgeInsets(top: 0, left: isLeft ? self.sidebarOuterPadding + self.sidebarWidth/2 : 0, bottom: 0, right: isLeft ? 0 : self.sidebarOuterPadding + self.sidebarWidth/2)))
        }
        self.leftSidebarCoverLabel = UILabel()
        self.leftSidebarCoverLabel.text = breakCharacters(self.leftSidebarCoverText)
        addCoverLabelForView(self.leftSidebarCoverLabel, self.leftSidebarCoverView, true)
        self.rightSidebarCoverLabel = UILabel()
        self.rightSidebarCoverLabel.text = breakCharacters(self.rightSidebarCoverText)
        addCoverLabelForView(self.rightSidebarCoverLabel, self.rightSidebarCoverView, false)
        
        // tap gesture recognizers
        self.leftSidebarTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSidebarTap:")
        self.leftSidebarView.addGestureRecognizer(self.leftSidebarTapGestureRecognizer)
        self.rightSidebarTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSidebarTap:")
        self.rightSidebarView.addGestureRecognizer(self.rightSidebarTapGestureRecognizer)
        
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
        scrollView.addSubview(self.leftSidebarView)
        self.leftSidebarView.frame = CGRect(x: -self.sidebarOuterPadding, y: 0, width: self.sidebarWidth + self.sidebarInnerPadding + self.sidebarOuterPadding, height: scrollView.contentSize.height)
        
        scrollView.addSubview(self.rightSidebarView)
        self.rightSidebarView.frame = CGRect(x: scrollView.contentSize.width - (self.sidebarWidth + self.sidebarInnerPadding), y: 0, width: self.sidebarWidth + self.sidebarInnerPadding + self.sidebarOuterPadding, height: scrollView.contentSize.height)
        
        scrollView.setContentOffset(self.calculatedContentOffset, animated: false)
    }
    
    public func handleSidebarTap(sender: UITapGestureRecognizer) {
        if sender.view == self.leftSidebarView {
            if self.sidebarState != .LeftSidebarShown {
                self.sidebarState = .LeftSidebarShown
                self.sidebarContainerScrollView.setContentOffset(self.calculatedContentOffset, animated: true)
            }
        } else if sender.view == self.rightSidebarView {
            if self.sidebarState != .RightSidebarShown {
                self.sidebarState = .RightSidebarShown
                self.sidebarContainerScrollView.setContentOffset(self.calculatedContentOffset, animated: true)
            }
        }
    }
    
    private func updateSidebarUserInteraction() {
        self.leftSidebarContentView.userInteractionEnabled = sidebarState == .LeftSidebarShown
        self.rightSidebarContentView.userInteractionEnabled = sidebarState == .RightSidebarShown
    }
    
    
    // MARK: Scroll View Delegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
//        let halfSidebarWidth = self.sidebarWidth/2
//        self.leftSidebarCoverView.alpha = min(max(scrollView.contentOffset.x / halfSidebarWidth, 0.0), 1.0)
//        self.rightSidebarCoverView.alpha = min(max((self.sidebarWidth - scrollView.contentOffset.x) / halfSidebarWidth, 0.0), 1.0)
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, var targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.sidebarContainerScrollView {
            switch self.sidebarState {
            case .Unselected:
                if velocity.x > 0 {
                    // sidebar moving forward, meaning content moving to the left
                    self.sidebarState = .RightSidebarShown
                } else if velocity.x < 0 {
                    self.sidebarState = .LeftSidebarShown
                } else {
                    // no velocity, tie break using target content offset
                    if targetContentOffset.memory.x > self.calculatedContentOffset.x {
                        self.sidebarState = .RightSidebarShown
                    } else if targetContentOffset.memory.x < self.calculatedContentOffset.x {
                        self.sidebarState = .LeftSidebarShown
                    }
                }
            case .LeftSidebarShown:
                // the only way to go to the right sidebar state from here is if the content offset is already closer to that
                let unselectedContentOffset = self.contentOffsetForDoubleSidebarState(.Unselected)
                if scrollView.contentOffset.x > unselectedContentOffset.x {
                    self.sidebarState = .RightSidebarShown
                } else {
                    // otherwise, if the velocity is positive or if target content offset is greater than the current content offset, then set it to unselected
                    if velocity.x > 0 || targetContentOffset.memory.x > self.calculatedContentOffset.x {
                        self.sidebarState = .Unselected
                    }
                }
            case .RightSidebarShown:
                // reverse the logic of the left state
                // the only way to go to the right sidebar state from here is if the content offset is already closer to that
                let unselectedContentOffset = self.contentOffsetForDoubleSidebarState(.Unselected)
                if scrollView.contentOffset.x < unselectedContentOffset.x {
                    self.sidebarState = .LeftSidebarShown
                } else {
                    // otherwise, if the velocity is positive or if target content offset is greater than the current content offset, then set it to unselected
                    if velocity.x < 0 || targetContentOffset.memory.x < self.calculatedContentOffset.x {
                        self.sidebarState = .Unselected
                    }
                }
            }
            targetContentOffset.put(self.calculatedContentOffset)
        }
    }
}

enum DoubleSidebarState {
    case Unselected, LeftSidebarShown, RightSidebarShown
}