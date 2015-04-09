//
//  URLConnectionObserver.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public final class URLConnectionObserver: NSObject, NSURLConnectionDataDelegate {
    public let progress: NSProgress = NSProgress(totalUnitCount: 1)
    private let incomingData: NSMutableData = NSMutableData()
    private var response: NSURLResponse?
    public let completionQueue: NSOperationQueue
    public let completion: (NSURLResponse?, NSData, NSError?)->Void
    
    init(completionQueue: NSOperationQueue?, completion: (NSURLResponse?, NSData, NSError?)->Void) {
        self.completionQueue = completionQueue ?? NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.completion = completion
    }
    
    // MARK: - URL Connection Data Delegate
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        self.progress.completedUnitCount = self.progress.totalUnitCount
        self.completionQueue.addOperationWithBlock {
            self.completion(self.response, self.incomingData.copy() as! NSData, nil)
        }
    }
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.incomingData.appendData(data)
        self.progress.completedUnitCount = min(self.progress.completedUnitCount + data.length, self.progress.totalUnitCount)
    }
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.progress.cancel()
        self.completionQueue.addOperationWithBlock {
            self.completion(self.response, self.incomingData.copy() as! NSData, error)
        }
    }
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.response = response
        if response.expectedContentLength >= 0 {
            self.progress.totalUnitCount = response.expectedContentLength
        }
    }
}
