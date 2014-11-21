//
//  URLConnectionExtension.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public extension NSURLConnection {
    public class func sendObservedAsynchronousRequest(request: NSURLRequest, queue: NSOperationQueue!,
        completionHandler handler: (NSURLResponse?,
        NSData,
        NSError?) -> Void) -> URLConnectionObserver {
            let observer = URLConnectionObserver(completionQueue: queue, completion: handler)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                // if this is problematic, try http://cocoaintheshell.com/2011/04/nsurlconnection-synchronous-asynchronous/
                let _ = NSURLConnection(request: request, delegate: observer, startImmediately: true)
            }
            return observer
    }
}