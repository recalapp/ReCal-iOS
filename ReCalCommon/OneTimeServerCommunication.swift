//
//  OneTimeServerCommunication.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/21/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

extension ServerCommunicator {
    public final class OneTimeServerCommunication : ServerCommunication {
        
        private let urlString: String
        private let completion: ServerCommunicator.Result->Void
        public override var request: NSURLRequest {
            return NSURLRequest(URL: NSURL(string: self.urlString)!)
        }
        public override var idleInterval: Int {
            return 1
        }
        
        public init(identifier: String, urlString: String, completion: ServerCommunicator.Result->Void) {
            self.urlString = urlString
            self.completion = completion
            super.init(identifier: identifier)
        }
        
        public override func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
            self.completion(result)
            return .Remove
        }
        
        public override func shouldSendRequest()->ServerCommunicator.ShouldSend {
            return .Send
        }
    }
}