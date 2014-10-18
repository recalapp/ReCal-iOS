//
//  TimeHeaderView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class TimeHeaderView: UICollectionReusableView {

    @IBOutlet weak var timeLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
        var layoutAttributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
        layoutAttributes.frame = CGRect(x: 0, y: 200, width: 100, height: 100)
        
        
        return layoutAttributes
    }
}
