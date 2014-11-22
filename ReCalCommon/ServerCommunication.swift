//
//  ServerCommunicationItem.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

extension ServerCommunicator {
    public class ServerCommunication {
        
        public var request: NSURLRequest {
            assertionFailure("Abstract method")
            return NSURLRequest()
        }
        public var idleInterval: Int {
            return 1
        }
        public let identifier: String
        internal(set) public var status: ServerCommunicator.CommunicationStatus = .Ready
        
        public init(identifier: String) {
            self.identifier = identifier
        }
        
        public func handleCommunicationResult(result: ServerCommunicator.Result) -> ServerCommunicator.CompleteAction {
            assertionFailure("Abstract method")
            return .Remove
        }
        
        public func shouldSendRequest()->ServerCommunicator.ShouldSend {
            return .Send
        }
    }
}