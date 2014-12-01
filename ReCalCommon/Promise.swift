//
//  Promise.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/25/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class Promise<SuccessType: AnyObject, ErrorType: AnyObject> {
    
    private var doneHandler: PromiseResult<SuccessType, ErrorType>->Void
    private var state: PromiseState<SuccessType, ErrorType>
    private let privateQueue: NSOperationQueue
    public init() {
        self.doneHandler = {(_) in }
        self.state = .Waiting
        self.privateQueue = {
            let queue = NSOperationQueue()
            queue.qualityOfService = .Utility
            queue.name = "Promise"
            queue.maxConcurrentOperationCount = 1;
            return queue
        }()
    }
    private func assertNotPrivateQueue() {
        assert(NSOperationQueue.currentQueue() != self.privateQueue, "Prevents deadlock")
    }
    private func performBlock(closure: ()->Void) {
        self.privateQueue.addOperationWithBlock(closure)
    }
    private func performBlockAndWait(closure: ()->Void) {
        self.assertNotPrivateQueue()
        let operation = NSBlockOperation(block: closure)
        self.privateQueue.addOperation(operation)
        operation.waitUntilFinished()
    }
    
    public func onDone(handler: PromiseResult<SuccessType, ErrorType>->Void) -> Promise<SuccessType, ErrorType> {
        let queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.performBlockAndWait {
            switch self.state {
            case .Waiting:
                let oldHandler = self.doneHandler
                self.doneHandler = {(result) in
                    oldHandler(result)
                    handler(result)
                    queue.addOperationWithBlock {
                        
                    }
                }
            case .Finished(.Success(let object)):
                queue.addOperationWithBlock  {
                    handler(.Success(object))
                }
            case .Finished(.Failure(let object)):
                queue.addOperationWithBlock {
                    handler(.Failure(object))
                }
            }
        }
        return self
    }
    
    public func onSuccess(handler: SuccessType->Void) -> Promise<SuccessType, ErrorType> {
        return self.onDone { (result) in
            switch result {
            case .Success(let object):
                handler(object)
            case .Failure(_):
                break
            }
        }
    }
    
    public func succeedWith(object: SuccessType) -> Promise<SuccessType, ErrorType> {
        let queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.performBlockAndWait {
            switch self.state {
            case .Waiting:
                self.state = .Finished(.Success(object))
                self.doneHandler(.Success(object))
                self.doneHandler = {(_) in }
                
            case .Finished(_):
                assertionFailure("Promise already finished")
                break
            }
        }
        return self
    }
    
    public func onFailure(handler: ErrorType->Void) -> Promise<SuccessType, ErrorType> {
        return self.onDone { (result) in
            switch result {
            case .Failure(let object):
                handler(object)
            case .Success(_):
                break
            }
        }
    }
    
    public func failWith(object: ErrorType) -> Promise<SuccessType, ErrorType> {
        let queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.performBlockAndWait {
            switch self.state {
            case .Waiting:
                self.state = .Finished(.Failure(object))
                self.doneHandler(.Failure(object))
                self.doneHandler = {(_) in }
            case .Finished(_):
                assertionFailure("Promise already finished")
                break
            }
        }
        return self
    }
}

public enum PromiseResult<SuccessType: AnyObject, ErrorType: AnyObject> {
    case Success(SuccessType)
    case Failure(ErrorType)
}
private enum PromiseState<SuccessType: AnyObject, ErrorType: AnyObject> {
    case Waiting
    case Finished(PromiseResult<SuccessType, ErrorType>)
}