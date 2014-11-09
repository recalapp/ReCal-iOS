//
//  AuthenticationViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/8/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController, UIWebViewDelegate {

    weak var delegate: AuthenticationViewControllerDelegate?
    var authenticationUrl: NSURL!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch Settings.currentSettings.theme {
        case .Light:
            self.navigationController?.navigationBar.barStyle = .Default
        case .Dark:
            self.navigationController?.navigationBar.barStyle = .Black
        }
        self.navigationController?.navigationBar.tintColor = Settings.currentSettings.colorScheme.actionableTextColor
    }
    
    override func viewDidAppear(animated: Bool) {
        let urlRequest = NSURLRequest(URL: self.authenticationUrl)
        self.webView.loadRequest(urlRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.delegate?.authenticationDidCancel(self)
    }

    // MARK: - Web View Delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        if self.authenticationUrl.isEqual(webView.request?.URL) {
            // if we got to this page, then we are done
            let username = webView.stringByEvaluatingJavaScriptFromString("document.body.innerText")
            self.delegate?.authentication(self, didAuthenticateWithUsername: username!)
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.delegate?.authenticationDidFail(self)
    }

}

protocol AuthenticationViewControllerDelegate: class {
    func authenticationDidFail(authenticationViewController: AuthenticationViewController)
    func authenticationDidCancel(authenticationViewController: AuthenticationViewController)
    func authentication(authenticationViewController: AuthenticationViewController, didAuthenticateWithUsername username: String)
}