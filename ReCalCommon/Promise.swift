//
//  Promise.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/25/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class Promise<SuccessType: NSObject, ErrorType: NSObject> {
    
    private var doneHandler: PromiseResult<SuccessType, ErrorType>->Void = {(_) in }
    private var state: PromiseState<SuccessType, ErrorType> = .Waiting
    public init() {
    }
    
    public func onDone(handler: PromiseResult<SuccessType, ErrorType>->Void) -> Promise<SuccessType, ErrorType> {
        var execute: (Void->Void)?
        synchronize(self) { ()->Void in
            switch self.state {
            case .Waiting:
                let oldHandler = self.doneHandler
                let queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
                self.doneHandler = {(result) in
                    oldHandler(result)
                    queue.addOperationWithBlock {
                        handler(result)
                    }
                }
            case .Success(let object):
                execute = {
                    handler(.Success(object))
                }
            case .Failure(let object):
                execute = {
                    handler(.Failure(object))
                }
            }
        }
        execute?()
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
        var execute: (Void->Void)?
        synchronize(self) { ()->Void in
            switch self.state {
            case .Waiting:
                self.state = .Success(object)
                let handler = self.doneHandler
                self.doneHandler = {(_) in }
                execute = {
                    handler(.Success(object))
                }
            case .Success(_), .Failure(_):
                assertionFailure("Promise already finished")
                break
            }
        }
        execute?()
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
        var execute: (Void->Void)?
        synchronize(self) { ()->Void in
            switch self.state {
            case .Waiting:
                self.state = .Failure(object)
                let handler = self.doneHandler
                self.doneHandler = {(_) in }
                execute = {
                    handler(.Failure(object))
                }
            case .Success(_), .Failure(_):
                assertionFailure("Promise already finished")
                break
            }
        }
        execute?()
        return self
    }
}

public enum PromiseResult<SuccessType: NSObject, ErrorType: NSObject> {
    case Success(SuccessType)
    case Failure(ErrorType)
}
private enum PromiseState<SuccessType: NSObject, ErrorType: NSObject> {
    case Waiting
    case Success(SuccessType)
    case Failure(ErrorType)
}