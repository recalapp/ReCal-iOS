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
    
    public subscript(identifier: String) -> ServerCommunication? {
        return self.identiferServerCommunicationMapping[identifier]
    }
    
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
        self.performBlock {
            for (_, serverCommunication) in self.identiferServerCommunicationMapping {
                self.advanceStateForServerCommunication(serverCommunication, reason: .TimerInterrupt)
            }
        }
    }
    
    private func advanceStateForServerCommunication(serverCommunication: ServerCommunication, reason: AdvanceReason) {
        self.assertPrivateQueue()
        switch serverCommunication.status {
        case .Connecting, .Processing:
            switch reason {
            case .Initial:
                serverCommunication.status = .Ready
            case .Manual, .TimerInterrupt:
                break
            }
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
            case .Initial:
                serverCommunication.status = .Ready
            }
        case .Ready:
            switch serverCommunication.shouldSendRequest() {
            case .Send:
                let observer = NSURLConnection.sendObservedAsynchronousRequest(serverCommunication.request, queue: self.serverCommunicationQueue, completionHandler: { (response, data, error) -> Void in
                    serverCommunication.status = .Processing
                    let result: Result = error != nil ? .Failure(error!) : .Success(response!, data)
                    switch serverCommunication.handleCommunicationResult(result) {
                    case .ConnectAgain:
                        serverCommunication.status = .Ready
                        return self.advanceStateForServerCommunication(serverCommunication, reason: .Manual)
                    case .NoAction:
                        serverCommunication.status = .Idle(serverCommunication.idleInterval)
                    }
                })
                serverCommunication.status = .Connecting(observer)
            case .Cancel:
                serverCommunication.status = .Idle(serverCommunication.idleInterval)
            case .NextInterrupt:
                serverCommunication.status = .Ready
            }
        }
    }
    
    public func registerServerCommunication(serverCommunication: ServerCommunication) {
        self.assertPrivateQueue()
        self.advanceStateForServerCommunication(serverCommunication, reason: .Initial)
        self.identiferServerCommunicationMapping[serverCommunication.identifier] = serverCommunication
    }
    
    public func unregisterServerCommunicationWithIdentifier(identifier: String) {
        self.assertPrivateQueue()
        assert(self[identifier] != nil, "Cannot unregister a communication that was never registered to begin with")
        self.identiferServerCommunicationMapping.removeValueForKey(identifier)
    }
    
    public func startServerCommunicationWithIdentifier(identifier: String) -> URLConnectionObserver? {
        self.assertPrivateQueue()
        assert(self[identifier] != nil, "Server communication with identifier \(identifier) does not exist")
        self.advanceStateForServerCommunication(self[identifier]!, reason: .Manual)
        switch self[identifier]!.status {
        case .Connecting(let observer):
            return observer
        case .Idle(_), .Processing, .Ready:
            return nil
        }
    }
    
    private func assertPrivateQueue() {
        assert(NSOperationQueue.currentQueue() == self.serverCommunicationQueue, "All operations on Server Communicator must be performed on its private queue via the performBlock() method or the performBlockAndWait() method")
    }
    
    public func performBlock(closure: ()->Void) {
        self.serverCommunicationQueue.addOperationWithBlock(closure)
    }
    
    public func performBlockAndWait(closure: ()->Void) {
        self.serverCommunicationQueue.addOperationWithBlock(closure)
        self.serverCommunicationQueue.waitUntilAllOperationsAreFinished()
    }
    
    private enum AdvanceReason {
        case TimerInterrupt
        case Manual
        case Initial
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
        case Connecting(URLConnectionObserver)
        case Processing
    }
}