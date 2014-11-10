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

    private var statusViewShown: Bool {
        switch Settings.currentSettings.authenticator.state {
        case .Authenticated(_), .Cached(_), .Unauthenticated:
            return false
        case .PreviouslyAuthenticated(_):
            return true
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLabel.text = "Error authenticating. Tap to retry."
        self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        self.statusLabel.textColor = Settings.currentSettings.colorScheme.alertTextColor
        self.statusView.backgroundColor = Settings.currentSettings.colorScheme.alertBackgroundColor
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(authenticatorStateDidChangeNofication, object: nil, queue: nil) { (_) -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }
        self.notificationObservers.append(observer)
        
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
        self.statusViewHeightConstraint?.constant = self.statusViewShown ? 20.0 : 0.0
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
        return self.statusViewShown
    }
}
