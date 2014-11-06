//
//  ManagedObjectProxy.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagedObjectProxy: Hashable {
    typealias ManagedObject : NSManagedObject
    init(managedObject: ManagedObject)
    var managedObjectProxyId: ManagedObjectProxyId { get }
    func commitToManagedObjectContext(managedObjectContext: NSManagedObjectContext)->ManagedObjectProxyCommitResult<ManagedObject>
}

public enum ManagedObjectProxyId: Hashable {
    case NewObject
    case Existing(NSManagedObjectID)
    
    public var hashValue: Int {
        switch self {
        case .Existing(let objectId):
            return objectId.hashValue
        case .NewObject:
            return 0
        }
    }
}

public func == (lhs: ManagedObjectProxyId, rhs: ManagedObjectProxyId) -> Bool {
    switch (lhs, rhs) {
    case (.Existing(let objectIdLhs), .Existing(let objectIdRhs)):
        return objectIdLhs.isEqual(objectIdRhs)
    case (.NewObject, .NewObject):
        return true
    default:
        return false
    }
}

public enum ManagedObjectProxyCommitResult<T: NSManagedObject> {
    case Success(T)
    case Failure
}