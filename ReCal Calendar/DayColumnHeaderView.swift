//
//  DayColumnHeaderView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/18/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class DayColumnHeaderView: UICollectionReusableView {
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var type: Type = .Normal {
        didSet {
            self.updateColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let updateColorScheme: ()->Void = {
            self.weekDayLabel.textColor = Settings.currentSettings.colorScheme.textColor
            self.dateLabel.textColor = Settings.currentSettings.colorScheme.textColor
            self.updateColor()
        }
        
        updateColorScheme()
        let observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.ThemeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (_) -> Void in
            updateColorScheme()
        }
        self.notificationObservers.append(observer1)
    }
    
    private var notificationObservers: [AnyObject] = []
    
    deinit {
        for observer in self.notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    private func updateColor() {
        switch self.type {
        case .Normal:
            self.backgroundColor = UIColor.clearColor()
        case .Today:
            self.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        }
    }
    
    enum Type {
        case Normal, Today
    }
}
