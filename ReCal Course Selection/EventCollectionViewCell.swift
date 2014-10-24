//
//  EventCollectionViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/23/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    let selectedAlpha: CGFloat = 1.0
    let unselectedAlpha: CGFloat = 0.8
    
    var event: ScheduleEvent? = nil {
        didSet {
            if let event = self.event {
                self.eventTitleLabel.text = event.title
            } else {
                self.eventTitleLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    var color: UIColor = UIColor.greenColor() {
        didSet {
            self.updateColor()
        }
    }
    
    override var selected: Bool {
        didSet {
            self.updateColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateColor()
    }

    private func updateColor() {
        let alpha = self.selected ? selectedAlpha : unselectedAlpha
        self.backgroundColor = self.color.colorWithAlphaComponent(alpha)
    }
    
    
}
