//
//  SummaryDaySummarizedView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class SummaryDaySummarizedView: UICollectionReusableView {
    @IBOutlet weak var backgroundLineView: UIView!
    @IBOutlet var gridLineViews: [UIView]!

    private var notificationObservers: [AnyObject] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let updateColorScheme: Void->Void = {
            self.backgroundLineView.backgroundColor = Settings.currentSettings.colorScheme.accessoryBackgroundColor
            for gridLine in self.gridLineViews {
                gridLine.backgroundColor = Settings.currentSettings.colorScheme.secondaryContentBackgroundColor
            }
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
