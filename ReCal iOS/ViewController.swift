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
        let cache = Cache<Int, String>(itemConstructor: {(key: Int) in
            println("Creating for \(key)")
            return "test \(key)"
        })
        println(cache[1])
        println(cache[2])
        println(cache[1])
        for (key, value) in cache {
            println("\(key): \(value)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

