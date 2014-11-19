//
//  AuthenticationContainerViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/9/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public let authenticationContainerEmbedSegueId = "AuthenticationContainerEmbed"

public class AuthenticationContainerViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusViewHeightConstraint: NSLayoutConstraint!
    
    private var notificationObservers: [AnyObject] = []

    private var statusViewState: StatusViewState {
        switch Settings.currentSettings.authenticator.state {
        case .Authenticated(_), .Cached(_), .Unauthenticated:
            return .NotShown
        case .PreviouslyAuthenticated(_):
            return .Shown("Error authenticating. Tap to retry.")
        case .Demo(_):
            return .Shown("Demo")
        }
    }
    
    private var statusViewHeight: CGFloat {
        switch self.statusViewState {
        case .NotShown:
            return 0
        case .Shown(_):
            return 20
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let updateWithColorScheme: (ColorScheme)->Void = {(colorScheme) in
            self.view.backgroundColor = colorScheme.accessoryBackgroundColor
            self.statusLabel.textColor = colorScheme.alertTextColor
            self.statusView.backgroundColor = colorScheme.alertBackgroundColor
        }
        updateWithColorScheme(Settings.currentSettings.colorScheme)
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(authenticatorStateDidChangeNofication, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            self.setNeedsAuthenticationStatusViewAppearanceUpdate()
        }
        let observer2 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateWithColorScheme(Settings.currentSettings.colorScheme)
        }
        self.notificationObservers.append(observer)
        self.notificationObservers.append(observer2)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleStatusViewTap:")
        self.statusView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func handleStatusViewTap(sender: UITapGestureRecognizer) {
        Settings.currentSettings.authenticator.authenticate()
    }
    
    public override func viewDidAppear(animated: Bool) {
        self.setNeedsAuthenticationStatusViewAppearanceUpdate()
    }
    
    private func setNeedsAuthenticationStatusViewAppearanceUpdate() {
        self.statusViewHeightConstraint?.constant = self.statusViewHeight
        switch self.statusViewState {
        case .NotShown:
            self.statusLabel.text = ""
        case .Shown(let statusString):
            self.statusLabel.text = statusString
        }
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.layoutIfNeeded()
            }, completion: { (completed) -> Void in
                
        })
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        var originalSize = super.sizeForChildContentContainer(container, withParentContainerSize: parentSize)
        originalSize.height -= self.statusViewHeight
        return originalSize
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        switch Settings.currentSettings.theme {
        case .Light:
            return .Default
        case .Dark:
            return .LightContent
        }
    }
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    public override func prefersStatusBarHidden() -> Bool {
        switch self.statusViewState {
        case .NotShown:
            return false
        case .Shown(_):
            return true
        }
    }
    
    private enum StatusViewState {
        case NotShown
        case Shown(String)
    }
}
