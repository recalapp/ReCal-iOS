//
//  EventsCollectionViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/18/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class EventsCollectionViewCell: UICollectionViewCell {

    
    let selectedColor = UIColor.redColor()
    var deselectedColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.deselectedColor = self.backgroundColor
    }

    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
        return super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
    }
    
    override var selected: Bool {
        didSet {
            if (self.selected) {
                self.backgroundColor = self.selectedColor
            }
            else {
                self.backgroundColor = self.deselectedColor
            }
        }
    }
}
