//
//  StaticTableViewDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public final class StaticTableViewDataSource : NSObject, UITableViewDataSource {
    private var sections: [SectionInfo] = []
    public subscript(sectionIndex: Int)->SectionInfo {
        return self.sections[sectionIndex]
    }
    public subscript(sectionIndex: Int, itemIndex: Int)->ItemInfo {
        return self.sections[sectionIndex][itemIndex]
    }
    public var numberOfSections: Int {
        return self.sections.count
    }
    public func setSectionInfos(sectionInfos: [SectionInfo]) {
        self.sections = sectionInfos
    }
    // MARK: - Table View Data Source
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[section].numberOfItems
    }
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let itemInfo = self[indexPath.section, indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(itemInfo.cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.textColor = Settings.currentSettings.colorScheme.textColor
        cell.detailTextLabel?.textColor = Settings.currentSettings.colorScheme.textColor
        cell.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        return itemInfo.cellProcessBlock(cell)
    }
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self[section]
        switch sectionInfo.name {
        case .Literal(let name):
            return name
        case .Empty:
            return nil
        }
    }
}
public extension StaticTableViewDataSource {
    public struct SectionInfo {
        public let name: SectionName
        public let items: [ItemInfo]
        public var numberOfItems: Int {
            return items.count
        }
        public subscript(itemIndex: Int)->ItemInfo {
            return items[itemIndex]
        }
        public enum SectionName {
            case Literal(String)
            case Empty
        }
        
        public init(name: SectionName, items: [ItemInfo]) {
            self.name = name
            self.items = items
        }
    }
    public struct ItemInfo {
        public let cellIdentifier: String
        public let cellProcessBlock: (UITableViewCell)->UITableViewCell
        public init(cellIdentifier: String, cellProcessBlock: (UITableViewCell)->UITableViewCell) {
            self.cellIdentifier = cellIdentifier
            self.cellProcessBlock = cellProcessBlock
        }
    }
}