//
//  GridLineView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/17/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class GridLineView: UICollectionReusableView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.lightGrayColor()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
    }
}
