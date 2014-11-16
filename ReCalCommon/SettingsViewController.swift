//
//  SettingsViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let storyboardId = "Settings"

public class SettingsViewController: UITableViewController {
    
    public weak var delegate: SettingsViewControllerDelegate?
    
    private typealias SectionInfo = StaticTableViewDataSource.SectionInfo
    private typealias ItemInfo = StaticTableViewDataSource.ItemInfo
    private let dataSource = StaticTableViewDataSource()
    
    private let recalAppsSection = 0
    private let courseSelectionRow = 0
    private let calendarRow = 1
    
    public class func instantiateFromStoryboard() -> SettingsViewController {
        let storyboard = UIStoryboard(name: "ReCalCommon", bundle: NSBundle(identifier: "io.recal.ReCalCommon"))
        return storyboard.instantiateViewControllerWithIdentifier(storyboardId) as SettingsViewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let recalAppsSection = SectionInfo(name: .Empty, items: [
            ItemInfo(cellIdentifier: "Basic", cellProcessBlock: { (cell) -> UITableViewCell in
                cell.textLabel.text = "Course Selection"
                return cell
            }),
            ItemInfo(cellIdentifier: "Basic", cellProcessBlock: { (cell) -> UITableViewCell in
                cell.textLabel.text = "Calendar"
                return cell
            })
        ])
        self.dataSource.setSectionInfos([recalAppsSection])
        self.tableView.dataSource = self.dataSource
        self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
    }

    
    // MARK: - Table View Delegate
    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (recalAppsSection, _):
            return true
        default:
            return false
        }
    }
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (recalAppsSection, courseSelectionRow):
            UIApplication.sharedApplication().openURL(NSURL(string: courseSelectionUrl)!)
        case (recalAppsSection, calendarRow):
            UIApplication.sharedApplication().openURL(NSURL(string: calendarUrl)!)
        default:
            break
        }
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func dismissButtonTapped(sender: UIBarButtonItem) {
        self.delegate?.settingsViewControllerDidTapDismissButton(self)
    }
}

public protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerDidTapDismissButton(settingsViewController: SettingsViewController)
}
