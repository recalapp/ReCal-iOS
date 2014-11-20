//
//  SettingsViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let storyboardId = "Settings"
private let basicCellIdentifier = "Basic"
private let centerCellIdentifier = "Center"
private let switchCellIdentifier = "Switch"
private let calendarBundleIdentifier = "io.recal.ReCal-Calendar"
private let courseSelectionBundleIdentifier = "io.recal.ReCal-Course-Selection"

public class SettingsViewController: UITableViewController, SettingsSwitchTableViewCellDelegate {
    
    public weak var delegate: SettingsViewControllerDelegate?
    
    private typealias SectionInfo = StaticTableViewDataSource.SectionInfo
    private typealias ItemInfo = StaticTableViewDataSource.ItemInfo
    private let dataSource = StaticTableViewDataSource()
    
    private let recalAppsSection = 1
    private let courseSelectionRow = 0
    private let calendarRow = 1
    
    private let logOutSection = 3
    
    public class func instantiateFromStoryboard() -> SettingsViewController {
        let storyboard = UIStoryboard(name: "ReCalCommon", bundle: NSBundle(identifier: "io.recal.ReCalCommon"))
        return storyboard.instantiateViewControllerWithIdentifier(storyboardId) as SettingsViewController
    }
    
    private var notificationObservers: [AnyObject] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let nameSection = SectionInfo(name: .Literal("Logged in as:"), items: [
            ItemInfo(cellIdentifier: centerCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                let centerCell = cell as SettingsCenterTableViewCell
                switch Settings.currentSettings.authenticator.state {
                case .Authenticated(let user):
                    centerCell.centerLabel.text = user.username
                case .PreviouslyAuthenticated(let user):
                    centerCell.centerLabel.text = user.username
                case .Cached(let user):
                    centerCell.centerLabel.text = user.username
                case .Demo(let user):
                    centerCell.centerLabel.text = user.username
                case .Unauthenticated:
                    centerCell.centerLabel.text = "(Not signed in)"
                }
                return centerCell
            })
        ])
        let recalAppsSection = SectionInfo(name: .Empty, items: [
            ItemInfo(cellIdentifier: basicCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                cell.textLabel.text = "Course Selection"
                if NSBundle.mainBundle().bundleIdentifier == courseSelectionBundleIdentifier {
                    cell.backgroundColor = Settings.currentSettings.colorScheme.selectedContentBackgroundColor
                }
                return cell
            }),
            ItemInfo(cellIdentifier: basicCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                cell.textLabel.text = "Calendar"
                if NSBundle.mainBundle().bundleIdentifier == calendarBundleIdentifier {
                    cell.backgroundColor = Settings.currentSettings.colorScheme.selectedContentBackgroundColor
                }
                return cell
            })
        ])
        let preferencesSection = SectionInfo(name: .Literal("Preferences"), items: [
            ItemInfo(cellIdentifier: switchCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                let switchCell = cell as SettingsSwitchTableViewCell
                switchCell.delegate = self
                switchCell.label.text = "Dark Mode"
                if Settings.currentSettings.colorScheme is DarkColorScheme {
                    switchCell.switchControl.on = true
                } else {
                    switchCell.switchControl.on = false
                }
                return switchCell
            })
        ])
        let logOutSection = SectionInfo(name: .Empty, items: [
            ItemInfo(cellIdentifier: centerCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                let centerCell = cell as SettingsCenterTableViewCell
                centerCell.centerLabel.textColor = Settings.currentSettings.colorScheme.alertBackgroundColor
                centerCell.centerLabel.text = "Log Out"
                return centerCell
            })
        ])
        self.dataSource.setSectionInfos([nameSection, recalAppsSection, preferencesSection, logOutSection])
        self.tableView.dataSource = self.dataSource
        
        
        let updateColorScheme: ()->Void = {
            self.view.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            self.tableView.reloadData()
        }
        updateColorScheme()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        self.notificationObservers.append(observer1)
    }

    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    // MARK: - Table View Delegate
    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (recalAppsSection, _):
            return true
        case (logOutSection, _):
            return true
        default:
            return false
        }
    }
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (recalAppsSection, courseSelectionRow):
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            UIApplication.sharedApplication().openURL(NSURL(string: Urls.courseSelection)!)
        case (recalAppsSection, calendarRow):
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            UIApplication.sharedApplication().openURL(NSURL(string: Urls.calendar)!)
        case (logOutSection, _):
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.delegate?.settingsViewControllerDidTapLogOutButton(self)
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
    
    // MARK: - Settings Switch Table View Cell Delegate
    func settingsSwitchTableViewCell(cell: SettingsSwitchTableViewCell, valueDidChange selected: Bool) {
        if selected {
            Settings.currentSettings.theme = .Dark
        } else {
            Settings.currentSettings.theme = .Light
        }
    }
}

public protocol SettingsViewControllerDelegate: class {
    /// Called when dismiss button is tapped. Only used if SettingsViewController is in a NavigationController
    func settingsViewControllerDidTapDismissButton(settingsViewController: SettingsViewController)
    func settingsViewControllerDidTapLogOutButton(settingsViewController: SettingsViewController)
}
