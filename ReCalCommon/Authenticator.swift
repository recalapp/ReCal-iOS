//
//  Authenticator.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/8/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let authenticationNavigationControllerStoryboardId = "Authentication"
private let authenticationUserDefaultsKey = "authenticationUserDefaultsKey"

public let authenticatorStateDidChangeNofication = "AuthenticatorStateDidChangeNofication"
public let authenticatorUserInfoKeyOldValue = "authenticatorUserInfoKeyOldValue"

public class Authenticator: AuthenticationViewControllerDelegate {
    public let rootViewController: UIViewController
    public let authenticationUrl: NSURL
    public let logOutUrl: NSURL
    
    public var user: User? {
        switch self.state {
        case .Unauthenticated, .Demo(_):
            return nil
        case .PreviouslyAuthenticated(let user):
            return user
        case .Authenticated(let user):
            return user
        case .Cached(let user):
            return user
        }
    }
    
    public init(rootViewController: UIViewController, forAuthenticationUrlString urlString: String, withLogOutUrlString logOutUrlString: String) {
        self.rootViewController = rootViewController
        self.authenticationUrl = NSURL(string: urlString)!
        self.logOutUrl = NSURL(string: logOutUrlString)!
        if let userSerialized = NSUserDefaults.standardUserDefaults().objectForKey(authenticationUserDefaultsKey) as? SerializedDictionary {
            let user = User(serializedDictionary: userSerialized)
            if user.isRealUser {
                self.state = .Cached(user)
            } else {
                self.state = .Demo(user)
            }
        } else {
            self.state = .Unauthenticated
        }
    }
    
    private(set) public var state: AuthenticationStatus = .Unauthenticated {
        didSet {
            if oldValue != state {
                NSNotificationCenter.defaultCenter().postNotificationName(authenticatorStateDidChangeNofication, object: self)
                switch state {
                case .Authenticated(let user):
                    NSUserDefaults.standardUserDefaults().setObject(user.serialize(), forKey: authenticationUserDefaultsKey)
                case .Cached(let user):
                    assertionFailure("Should not get here. We never transition a state to cache, but we may start the state off as cached in the initializer")
                    NSUserDefaults.standardUserDefaults().setObject(user.serialize(), forKey: authenticationUserDefaultsKey)
                case .PreviouslyAuthenticated(let user):
                    NSUserDefaults.standardUserDefaults().setObject(user.serialize(), forKey: authenticationUserDefaultsKey)
                case .Demo(let user):
                    NSUserDefaults.standardUserDefaults().setObject(user.serialize(), forKey: authenticationUserDefaultsKey)
                    break
                case .Unauthenticated:
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(authenticationUserDefaultsKey)
                }
                
            }
        }
    }
    
    lazy private var authenticationNavigationController: UINavigationController = {
        let vc = UIStoryboard(name: "ReCalCommon", bundle: NSBundle(identifier: "io.recal.ReCalCommon")).instantiateViewControllerWithIdentifier(authenticationNavigationControllerStoryboardId) as UINavigationController
        let authVC = (vc.visibleViewController as AuthenticationViewController)
        authVC.delegate = self
        authVC.authenticationUrl = self.authenticationUrl
        return vc
    }()
    
    /// Check whether the user is authenticated. If he is, then return. Otherwise, present a view controller from rootViewController to authenticate the user. The function returns right away, so the thread is not blocked. Therefore, the caller must check the status to see if the authentication was successful
    public func authenticate() {
        func authenticateDemo() {
            return
        }
        func authenticateRealUser() {
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
                self.advanceStateWithAuthenticationResult(.Failure)
            } else {
                if let response = responseOpt as? NSHTTPURLResponse {
                    if self.authenticationUrl.isEqual(response.URL) && response.statusCode == 200 {
                        // no redirection, and connection was successful, meaning data returned is the username
                        let content = NSString(data: data!, encoding: NSASCIIStringEncoding) as String
                        let components = split(content, { $0 == " " }, allowEmptySlices:false)
                        if components.count == 2 {
                            self.advanceStateWithAuthenticationResult(.Success(components[0], components[1]))
                        } else {
                            self.advanceStateWithAuthenticationResult(.Failure)
                        }
                    } else {
                        // redirection occurred. Present a view controller to let the user log in
                        self.advanceStateWithAuthenticationResult(.Failure)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            if self.rootViewController.presentedViewController != self.authenticationNavigationController {
                                self.rootViewController.presentViewController(self.authenticationNavigationController, animated: true, completion: {(_) in
                                    println("here")
                                })
                            }
                        }
                    }
                } else {
                    self.advanceStateWithAuthenticationResult(.Failure)
                }
            }
        }
        switch self.state {
        case .Demo(_):
            return authenticateDemo()
        case .Authenticated(_), .PreviouslyAuthenticated(_), .Cached(_), .Unauthenticated:
            return authenticateRealUser()
        }
    }
    
    /// Logs the user out. Sends an asynchronous web request to log off on the server. Therefore, on return, the logout may not actually have happened on the server yet.
    public func logOut() {
        let request = NSURLRequest(URL: self.logOutUrl)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.currentQueue()) { (_, _, _) in
            
        }
        self.advanceStateWithAuthenticationResult(.LogOut)
    }
    
    public func logInAsDemo() {
        self.advanceStateWithAuthenticationResult(.SuccessDemo)
    }
    
    private func advanceStateWithAuthenticationResult(result: AuthenticationResult) {
        switch self.state {
        case .Authenticated(let user):
            switch result {
            case .Success(let username, let userId):
                self.state = .Authenticated(User(username: username, userId: userId))
            case .LogOut:
                self.state = .Unauthenticated
            case .Failure:
                self.state = .PreviouslyAuthenticated(user)
            case .SuccessDemo:
                assertionFailure("Cannot start demo from a state other than unauthenticated")
            }
        case .Cached(let user):
            switch result {
            case .Success(let username, let userId):
                self.state = .Authenticated(User(username: username, userId: userId))
            case .LogOut:
                self.state = .Unauthenticated
            case .Failure:
                self.state = .PreviouslyAuthenticated(user)
            case .SuccessDemo:
                assertionFailure("Cannot start demo from a state other than unauthenticated")
            }
        case .PreviouslyAuthenticated(_):
            switch result {
            case .Success(let username, let userId):
                self.state = .Authenticated(User(username: username, userId: userId))
            case .LogOut:
                self.state = .Unauthenticated
            case .Failure:
                break
            case .SuccessDemo:
                assertionFailure("Cannot start demo from a state other than unauthenticated")
            }
        case .Demo(_):
            switch result {
            case .Success(let username, let userId):
                assertionFailure("Should never get here")
                self.state = .Demo(User(username: username, userId: userId))
            case .Failure:
                assertionFailure("Should never get here")
            case .LogOut:
                self.state = .Unauthenticated
            case .SuccessDemo:
                break
            }
        case .Unauthenticated:
            switch result {
            case .Success(let username, let userId):
                self.state = .Authenticated(User(username: username, userId: userId))
            case .SuccessDemo:
                self.state = .Demo(User(username: "(demo)", isRealUser: false))
            case .Failure, .LogOut:
                break
            }
        }
    }
    
    // MARK: - Authentication View Controller Delegate
    func authenticationDidCancel(authenticationViewController: AuthenticationViewController) {
        self.rootViewController.dismissViewControllerAnimated(true, completion: {
            self.advanceStateWithAuthenticationResult(.Failure)
        })
    }
    func authentication(authenticationViewController: AuthenticationViewController, didAuthenticateWithUsername username: String, userId: String) {
        self.rootViewController.dismissViewControllerAnimated(true, completion: {
            self.advanceStateWithAuthenticationResult(.Success(username, userId))
        })
    }
    func authenticationDidFail(authenticationViewController: AuthenticationViewController) {
        self.rootViewController.dismissViewControllerAnimated(true, completion: {
            let alertVC = UIAlertController(title: "Error authenticating", message: "We are having some trouble logging you in right now. Please try again later.", preferredStyle:.Alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) in
                self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.rootViewController.presentViewController(alertVC, animated: true, completion: nil)
            self.advanceStateWithAuthenticationResult(.Failure)
        })
    }
}

/// used as input to DFA
private enum AuthenticationResult {
    case Success(String, String)
    case SuccessDemo
    case Failure
    case LogOut
}

public enum AuthenticationStatus: Equatable {
    case Authenticated(User)
    case PreviouslyAuthenticated(User)
    case Cached(User) // starting state if we cached a user
    case Demo(User)
    case Unauthenticated
}

public func == (lhs: AuthenticationStatus, rhs: AuthenticationStatus) -> Bool {
    switch (lhs, rhs) {
    case (.Authenticated(let userLhs), .Authenticated(let userRhs)):
        return userLhs == userRhs
    case (.PreviouslyAuthenticated(let userLhs), .PreviouslyAuthenticated(let userRhs)):
        return userLhs == userRhs
    case (.Cached(let userLhs), .Cached(let userRhs)):
        return userLhs == userRhs
    case (.Unauthenticated, .Unauthenticated):
        return true
    case (.Demo(let userLhs), .Demo(let userRhs)):
        return userLhs == userRhs
    case (.Authenticated(_), _), (.PreviouslyAuthenticated(_), _), (.Cached(_), _), (.Unauthenticated, _), (.Demo, _):
        // avoids a default clause
        return false
    }
}

public struct User: Equatable, Serializable {
    public let username: String
    public let userId: String
    private let serializedDictionaryKeyUser = "user"
    private let serializedDictionaryKeyUserId = "userId"
    private let serializedDictionaryKeyIsReal = "isReal"
    private let isRealUser: Bool = true
    public init(username: String, userId: String) {
        self.username = username
        self.userId = userId
    }
    public init(username: String, isRealUser: Bool) {
        self.username = username
        self.userId = ""
        self.isRealUser = isRealUser
    }
    public init(serializedDictionary: SerializedDictionary) {
        self.username = serializedDictionary[serializedDictionaryKeyUser]! as String
        self.isRealUser = serializedDictionary[serializedDictionaryKeyIsReal]! as Bool
        self.userId = serializedDictionary[serializedDictionaryKeyUserId]! as String
    }
    public func serialize() -> SerializedDictionary {
        return [serializedDictionaryKeyUser: self.username, serializedDictionaryKeyIsReal: self.isRealUser, serializedDictionaryKeyUserId: self.userId]
    }
}

public func == (lhs: User, rhs: User) -> Bool {
    if lhs.username != rhs.username {
        return false
    }
    return true
}