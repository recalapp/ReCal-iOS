//
//  CourseDetailsViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/2/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let singleLabelCellReuseIdentifier = "SingleLabel"

class CourseDetailsViewController: UITableViewController {

    private typealias SectionInfo = StaticTableViewDataSource.SectionInfo
    private typealias ItemInfo = StaticTableViewDataSource.ItemInfo
    
    var course: Course? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var notificationObservers: [AnyObject] = []
    private let staticTableViewDataSource: StaticTableViewDataSource = StaticTableViewDataSource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let updateColorScheme: ()->Void = {
            self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
        }
        updateColorScheme()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
            self.tableView.reloadData()
        }
        let nameSection = SectionInfo(name: .Empty, items: [
            ItemInfo(cellIdentifier: singleLabelCellReuseIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                if let course = self.course {
                    let label = cell.contentView.viewWithTag(1) as! UILabel
                    label.text = join("/", course.courseListings.map { $0.description } as [String])
                    label.textColor = Settings.currentSettings.colorScheme.textColor
                }
                cell.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
                return cell
            }),
            ItemInfo(cellIdentifier: singleLabelCellReuseIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
            if let course = self.course {
                let label = cell.contentView.viewWithTag(1) as! UILabel
                label.text = course.title
                label.textColor = Settings.currentSettings.colorScheme.textColor
            }
            cell.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
            return cell
            })
        ])
        let descriptionSection = SectionInfo(name: .Literal("Description"), items: [
            ItemInfo(cellIdentifier: singleLabelCellReuseIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
            if let course = self.course {
                let label = cell.contentView.viewWithTag(1) as! UILabel
                label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                label.text = course.courseDescription
                label.textColor = Settings.currentSettings.colorScheme.textColor
            }
            cell.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
            return cell
            })
        ])
        self.staticTableViewDataSource.setSectionInfos([nameSection, descriptionSection])
        self.tableView.dataSource = self.staticTableViewDataSource
        self.tableView.estimatedRowHeight = 44
        self.notificationObservers.append(observer1)
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
}
