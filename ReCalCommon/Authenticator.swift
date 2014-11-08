//
//  Authenticator.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/8/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let authenticationNavigationControllerStoryboardId = "Authentication"

public class Authenticator: AuthenticationViewControllerDelegate {
    public let rootViewController: UIViewController
    public let authenticationUrl: NSURL
    public init(rootViewController: UIViewController, forAuthenticationUrlString urlString: String) {
        self.rootViewController = rootViewController
        self.authenticationUrl = NSURL(string: urlString)!
    }
    
    private(set) public var status: AuthenticationStatus = .Unauthenticated
    
    lazy private var authenticationNavigationController: UINavigationController = {
        let vc = UIStoryboard(name: "ReCalCommon", bundle: NSBundle(identifier: "io.recal.ReCalCommon")).instantiateViewControllerWithIdentifier(authenticationNavigationControllerStoryboardId) as UINavigationController
        let authVC = (vc.visibleViewController as AuthenticationViewController)
        authVC.delegate = self
        authVC.authenticationUrl = self.authenticationUrl
        return vc
    }()
    
    /// Check whether the user is authenticated. If he is, then return. Otherwise, present a view controller from rootViewController to authenticate the user. The function returns right away, so the thread is not blocked. Therefore, the caller must check the status to see if the authentication was successful
    public func authenticate() {
        let fail: ()->Void = {
            switch self.status {
            case let .Authenticated(user):
                self.status = .PreviouslyAuthenticated(user)
            case let .PreviouslyAuthenticated(user):
                self.status = .PreviouslyAuthenticated(user)
            case .Unauthenticated:
                self.status = .Unauthenticated
            }
        }
        let urlRequest: NSURLRequest = {
            let request = NSURLRequest(URL: self.authenticationUrl, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            return request
        }()
        var responseOpt: NSURLResponse?
        var errorOpt: NSError?
        let data = NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: &responseOpt, error: &errorOpt)
        if let error = errorOpt {
            // connection error. Cannot do anything, so just return
            println("Error connecting. Error: \(error)")
            fail()
        } else {
            if let response = responseOpt as? NSHTTPURLResponse {
                if self.authenticationUrl.isEqual(response.URL) && response.statusCode == 200 {
                    // no redirection, and connection was successful, meaning data returned is the username
                    let username = NSString(data: data!, encoding: NSASCIIStringEncoding)
                    let user = User(username: username!)
                    self.status = .Authenticated(user)
                } else {
                    // redirection occurred. Present a view controller to let the user log in
                    fail()
                    self.rootViewController.presentViewController(self.authenticationNavigationController, animated: true, completion: nil)
                }
            } else {
                fail()
            }
        }
    }
    
    // MARK: - Authentication View Controller Delegate
    func authenticationDidCancel(authenticationViewController: AuthenticationViewController) {
        switch self.status {
        case let .Authenticated(user):
            self.status = .PreviouslyAuthenticated(user)
        case let .PreviouslyAuthenticated(user):
            self.status = .PreviouslyAuthenticated(user)
        case .Unauthenticated:
            self.status = .Unauthenticated
        }
        self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    func authentication(authenticationViewController: AuthenticationViewController, didAuthenticateWithUsername username: String) {
        let user = User(username: username)
        self.status = .Authenticated(user)
        self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    func authenticationDidFail(authenticationViewController: AuthenticationViewController) {
        switch self.status {
        case let .Authenticated(user):
            self.status = .PreviouslyAuthenticated(user)
        case let .PreviouslyAuthenticated(user):
            self.status = .PreviouslyAuthenticated(user)
        case .Unauthenticated:
            self.status = .Unauthenticated
        }
        self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

public enum AuthenticationStatus {
    case Authenticated(User)
    case PreviouslyAuthenticated(User)
    case Unauthenticated
}

public struct User {
    let username: String
}