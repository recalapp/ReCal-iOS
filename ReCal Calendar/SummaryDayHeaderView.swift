//
//  SummaryDayHeaderView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SummaryDayHeaderView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    
    private var notificationObservers: [AnyObject] = []
    
    override init() {
        super.init()
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    private func initialize() {
        self.headerLabel = {
            let headerLabel = UILabel()
            headerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            headerLabel.font = UIFont.systemFontOfSize(20)
            self.addSubview(headerLabel)
            let verticalConstraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: headerLabel, attribute: .CenterY, multiplier: 1.0, constant: 0)
            let leadingConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: headerLabel, attribute: .Leading, multiplier: 1.0, constant: -8.0)
            self.addConstraints([verticalConstraint, leadingConstraint])
            return headerLabel
        }()
        
        let updateColorScheme: Void->Void = {
            self.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            self.headerLabel.textColor = Settings.currentSettings.colorScheme.textColor
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
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
