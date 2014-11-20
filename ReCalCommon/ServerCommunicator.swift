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
        queue.name = "Server Communicator"
        queue.qualityOfService = NSQualityOfService.Utility
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private let timer: NSTimer!
    
    public convenience init() {
        self.init(interruptInterval: 5)
    }
    
    public init(interruptInterval: NSTimeInterval) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interruptInterval, target: self, selector: Selector("handleTimerInterrupt:"), userInfo: nil, repeats: true)
    }
    deinit {
        self.timer.invalidate()
    }
    
    @objc public func handleTimerInterrupt(_: NSTimer) {
        self.serverCommunicationQueue.addOperationWithBlock {
            for (_, serverCommunication) in self.identiferServerCommunicationMapping {
                self.advanceStateForServerCommunication(serverCommunication, reason: .TimerInterrupt)
            }
        }
    }
    
    private func advanceStateForServerCommunication(serverCommunication: ServerCommunication, reason: AdvanceReason) {
        assert(NSOperationQueue.currentQueue() == self.serverCommunicationQueue, "Must be on the server communication queue")
        switch serverCommunication.status {
        case .Connecting, .Processing:
            break
        case .Idle(let remaining):
            switch reason {
            case .TimerInterrupt:
                if remaining == 0 {
                    serverCommunication.status = .Ready
                } else {
                    serverCommunication.status = .Idle(remaining - 1)
                }
            case .Manual:
                serverCommunication.status = .Ready
                return self.advanceStateForServerCommunication(serverCommunication, reason: reason)
            }
            
        case .Ready:
            switch serverCommunication.shouldSendRequest() {
            case .Send:
                serverCommunication.status = .Connecting
                NSURLConnection.sendAsynchronousRequest(serverCommunication.request, queue: self.serverCommunicationQueue, completionHandler: { (response, data, error) -> Void in
                    serverCommunication.status = .Processing
                    let result: Result = error != nil ? .Failure(error) : .Success(response, data)
                    switch serverCommunication.handleCommunicationResult(result) {
                    case .ConnectAgain:
                        serverCommunication.status = .Ready
                        return self.advanceStateForServerCommunication(serverCommunication, reason: .Manual)
                    case .NoAction:
                        serverCommunication.status = .Idle(serverCommunication.idleInterval)
                    }
                })
            case .Cancel:
                serverCommunication.status = .Idle(serverCommunication.idleInterval)
            case .NextInterrupt:
                serverCommunication.status = .Ready
            }
            
        }
    }
    
    public func registerServerCommunication(serverCommunication: ServerCommunication) {
        self.serverCommunicationQueue.addOperationWithBlock {
            self.identiferServerCommunicationMapping[serverCommunication.identifier] = serverCommunication
        }
    }
    
    public func unregisterServerCommunicationWithIdentifier(identifier: String) {
        assert(self.identiferServerCommunicationMapping[identifier] != nil, "Cannot unregister a communication that was never registered to begin with")
        self.serverCommunicationQueue.addOperationWithBlock {
            let _ = self.identiferServerCommunicationMapping.removeValueForKey(identifier)
        }
    }
    
    public func startServerCommunicationWithIdentifier(identifier: String) {
        assert(self.identiferServerCommunicationMapping[identifier] != nil, "Server communication with identifier \(identifier) does not exist")
        self.serverCommunicationQueue.addOperationWithBlock {
            self.advanceStateForServerCommunication(self.identiferServerCommunicationMapping[identifier]!, reason: .Manual)
        }
    }
    
    private enum AdvanceReason {
        case TimerInterrupt
        case Manual
    }
    public enum ShouldSend {
        case Send
        case Cancel
        case NextInterrupt
    }
    public enum Result {
        case Success(NSURLResponse, NSData)
        case Failure(NSError)
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