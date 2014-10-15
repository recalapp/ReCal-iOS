//
//  BasicDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

extension Array {
    func find(isIncludedElement: T -> Bool) -> [Int] {
        var indices: [Int] = []
        for (i, element) in enumerate(self) {
            if isIncludedElement(element) {
                indices.append(i)
            }
        }
        return indices
    }
}
// TODO: finish implementing
class BasicDataSource: BaseDataSource {
    var items: [AnyObject] = [];
    
    override func resetContent() {
        super.resetContent()
        self.items = []
    }
    
    override func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        var index = indexPath.item
        if index < self.items.count {
            return self.items[index]
        }
        return nil
    }
    
    override func indexPathsForItem(item: AnyObject) -> [NSIndexPath] {
        return self.items.find { (otherItem) in
            return otherItem === item
        }.map {(index: Int) in
            return NSIndexPath(forItem: index, inSection: 0)
        }
    }
}
