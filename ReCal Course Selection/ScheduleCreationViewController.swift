//
//  ScheduleCreationViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/6/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

private let nameCellIdentifier = "NameCell"
private let basicCellIdentifier = "Basic"

class ScheduleCreationViewController: UITableViewController, UITextFieldDelegate {
    private typealias SectionInfo = StaticTableViewDataSource.SectionInfo
    private typealias ItemInfo = StaticTableViewDataSource.ItemInfo
    
    weak var delegate: ScheduleSelectionDelegate?

    private var nameTextField: UITextField? {
        return self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.viewWithTag(1) as? UITextField
    }
    
    var managedObjectContext: NSManagedObjectContext!
    
    private var notificationObservers: [AnyObject] = []
    private let dataSource: StaticTableViewDataSource = StaticTableViewDataSource()
    
    private let semestersSectionIndex = 1
    private var semesters: [CDSemester] = []
    private var selectedSemester: CDSemester? {
        didSet {
            self.updateSaveButtonState()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nameSection = SectionInfo(name: .Literal("Schedule Name:"), items: [
            ItemInfo(cellIdentifier: nameCellIdentifier, cellProcessBlock: { (cell) -> UITableViewCell in
                if let nameTextField = cell.viewWithTag(1) as? UITextField {
                    nameTextField.textColor = Settings.currentSettings.colorScheme.textColor
                    nameTextField.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
                    switch Settings.currentSettings.theme {
                    case .Light:
                        nameTextField.keyboardAppearance = .Light
                    case .Dark:
                        nameTextField.keyboardAppearance = .Dark
                    }
                }
                return cell
            })
        ])
        let semestersSection = SectionInfo(name: .Literal("Semester:"), items: [])
        self.dataSource.setSectionInfos([nameSection, semestersSection])
        self.tableView.dataSource = self.dataSource
        let processSemesters: [CDSemester] -> Void = { (semesters: [CDSemester]) in
            self.semesters = semesters
            var itemInfos: [ItemInfo]?
            self.managedObjectContext.performBlockAndWait {
                itemInfos = self.semesters.map { (semester: CDSemester) -> ItemInfo in
                    var itemInfo = ItemInfo(cellIdentifier: basicCellIdentifier, selected: semester.termCode == self.selectedSemester?.termCode, cellProcessBlock: { (cell) -> UITableViewCell in
                            cell.textLabel.text = semester.termCode
                            return cell
                        })
                    return itemInfo
                }
            }
            let semestersSection = SectionInfo(name: self.dataSource[self.semestersSectionIndex].name, items: itemInfos!)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.dataSource[self.semestersSectionIndex] = semestersSection
                self.tableView.reloadSections(NSIndexSet(index: self.semestersSectionIndex), withRowAnimation: .None)
            }
            self.tableView.keyboardDismissMode = .OnDrag
        }
        self.fetchActiveSemesters(processSemesters)
        
        let updateColorScheme: ()->Void = {
            self.tableView.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            self.tableView.reloadData()
        }
        updateColorScheme()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        let observer2 = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            // no need to merge. We don't own the managed object context
            self.fetchActiveSemesters(processSemesters)
        }
        self.notificationObservers.append(observer1)
        self.notificationObservers.append(observer2)
    }
    
    private func fetchActiveSemesters(callBack: (([CDSemester])->Void)?) {
        let fetchRequest: NSFetchRequest = {
            let fetchRequest = NSFetchRequest(entityName: "CDSemester")
            fetchRequest.predicate = NSPredicate(format: "active = 1")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "termCode", ascending: false)]
            return fetchRequest
        }()
        let queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.managedObjectContext.performBlock {
            var errorOpt: NSError?
            let fetched = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt)
            if let error = errorOpt {
                println("Error fetching semesters. Error: \(error)")
                return
            }
            if let semesters = fetched as? [CDSemester] {
                queue.addOperationWithBlock {
                    let _ = callBack?(semesters)
                }
            }
        }
    }
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.nameTextField?.becomeFirstResponder()
    }

    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if let name = self.nameTextField?.text? {
            assert(self.selectedSemester != nil)
            var createdSchedule = Schedule(name: name, termCode: self.selectedSemester!.termCode)
            switch createdSchedule.commitToManagedObjectContext(self.managedObjectContext) {
            case .Success(let tempObjectId):
                var success = false
                var error: NSError?
                var schedule = self.managedObjectContext.objectWithID(tempObjectId) as CDSchedule
                self.managedObjectContext.performBlockAndWait {
                    success = self.managedObjectContext.save(&error)
                }
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                    self.delegate?.didSelectScheduleWithObjectId(schedule.objectID) // object id changes on save!
                } else {
                    println("error saving. error: \(error)")
                    assertionFailure("Failed to save schedule")
                }
            case .Failure:
                assertionFailure("Failed to save schedule")
                break
            }
        }
    }
    @IBAction func nameTextFieldValueChanged(sender: UITextField) {
        self.updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        self.navigationItem.rightBarButtonItem?.enabled = {
            if self.nameTextField == nil || self.nameTextField!.text == "" {
                return false
            }
            if self.selectedSemester == nil {
                return false
            }
            return true
        }()
    }
    
    /// MARK: - Table View Delegate
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == self.semestersSectionIndex // semester section
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        assert(indexPath.section == self.semestersSectionIndex, "Only semesters are selectable")
        assert(indexPath.row < self.dataSource[indexPath.section].numberOfItems)
        assert(indexPath.row < self.semesters.count)
        self.selectedSemester = self.semesters[indexPath.row]
        var itemInfo = self.dataSource[indexPath.section, indexPath.row]
        itemInfo.selected = true
        self.dataSource[indexPath.section, indexPath.row] = itemInfo
    }
}
