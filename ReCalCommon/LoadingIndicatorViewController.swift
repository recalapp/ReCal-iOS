//
//  LoadingIndicatorViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

private let storyboardId = "LoadingIndicator"

public class LoadingIndicatorViewController: UIViewController {
    
    @IBOutlet public var textLabel: UILabel!
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public class func instantiateFromStoryboard() -> LoadingIndicatorViewController {
        let storyboard = UIStoryboard(name: "ReCalCommon", bundle: NSBundle(identifier: "io.recal.ReCalCommon"))
        return storyboard.instantiateViewControllerWithIdentifier(storyboardId) as LoadingIndicatorViewController
    }
    
}
