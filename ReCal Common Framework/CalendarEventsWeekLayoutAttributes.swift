//
//  CalendarEventsWeekLayoutAttributes.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class CalendarEventsWeekLayoutAttributes: UICollectionViewLayoutAttributes {
    
    init(forCellWithIndexPath indexPath:NSIndexPath)
    {
        super.init()
        self.indexPath = indexPath
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if super.isEqual(object){
            return true
        }
        return false
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        if let copy = super.copyWithZone(zone) as? CalendarEventsWeekLayoutAttributes {
            return copy
        }
        assert(false, "Copying CalendarEventsWeekLayoutAttributes failed")
    }
}
