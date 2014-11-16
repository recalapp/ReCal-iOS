//
//  ServerCommunicator.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public final class ServerCommunicator {
    
    private var identiferServerCommunicationMapping: [String: ServerCommunication] = Dictionary()
    
    private var serverCommunicationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        return queue
    }()
    
    public convenience init() {
        self.init(interruptInterval: 5)
    }
    
    public init(interruptInterval: NSTimeInterval) {
        let timer = NSTimer(timeInterval: interruptInterval, target: self, selector: "handleTimerInterrupt", userInfo: nil, repeats: true)
    }
    
    private func handleTimerInterrupt() {
        for (_, serverCommunication) in self.identiferServerCommunicationMapping {
            self.advanceStateForServerCommunication(serverCommunication)
        }
    }
    
    private func advanceStateForServerCommunication(serverCommunication: ServerCommunication) {
        switch serverCommunication.status {
        case .Connecting, .Processing:
            break
        case .Idle(let remaining):
            if remaining == 0 {
                serverCommunication.status = .Ready
            } else {
                serverCommunication.status = .Idle(remaining - 1)
            }
        case .Ready:
            serverCommunication.status = .Connecting
            NSURLConnection.sendAsynchronousRequest(serverCommunication.request, queue: self.serverCommunicationQueue, completionHandler: { (response, data, error) -> Void in
                serverCommunication.status = .Processing
                let result: Result = error == nil ? .Failure(response, error) : .Success(response, data)
                switch serverCommunication.handleCommunicationResult(result) {
                case .ConnectAgain:
                    serverCommunication.status = .Ready
                    return self.advanceStateForServerCommunication(serverCommunication)
                case .NoAction:
                    serverCommunication.status = .Idle(serverCommunication.idleInterval)
                }
            })
        }
    }
    
    public func registerServerCommunication(serverCommunication: ServerCommunication) {
        assert(self.identiferServerCommunicationMapping[serverCommunication.identifier] == nil, "Server Communication with identifier \(serverCommunication.identifier) already exists")
        self.identiferServerCommunicationMapping[serverCommunication.identifier] = serverCommunication
    }
    
    public enum Result {
        case Success(NSURLResponse, NSData)
        case Failure(NSURLResponse, NSError)
    }
    public enum CompleteAction {
        case ConnectAgain
        case NoAction
    }
    public enum CommunicationStatus {
        // if the integer goes to 0, then transition to ready
        case Idle(Int)
        case Ready
        case Connecting
        case Processing
    }
}