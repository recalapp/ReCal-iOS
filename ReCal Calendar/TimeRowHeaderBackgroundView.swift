//
//  TimeRowHeaderBackgroundView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/18/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class TimeRowHeaderBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    private var notificationObservers: [AnyObject] = []
    private func initialize() {
        
        let updateColorScheme: ()->Void = {
            self.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
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
}
