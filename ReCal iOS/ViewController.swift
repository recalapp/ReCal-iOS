//
//  ViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/14/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let testControl = SlidingSelectionControl(items: ["test", "12345678"])
        let xConstraint = NSLayoutConstraint(item: testControl, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let yConstraint = NSLayoutConstraint(item: testControl, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 100.0)
//        let widthConstraint = NSLayoutConstraint(item: testControl, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200.0)
//        let heightConstraint = NSLayoutConstraint(item: testControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200.0)
//        testControl.addConstraints([widthConstraint, heightConstraint])
        self.view.addSubview(testControl)
        self.view.addConstraints([xConstraint, yConstraint])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

