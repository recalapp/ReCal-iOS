//
//  SummaryViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SummaryViewController: UIViewController {

    @IBOutlet weak var testSummaryView: SummaryDayView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.testSummaryView.viewModel = TestViewModel()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

private struct TestViewModel: SummaryDayViewModel {
    let events: [SummaryDayViewEvent]
    init() {
        self.events = [Event1(), Event2(), Event3()]
    }
    private struct Event1: SummaryDayViewEvent {
        let time: SummaryDayView.EventTime
        let title = "test"
        let color = UIColor.redColor()
        let highlightedColor = UIColor.redColor().darkerColor().darkerColor()
        init() {
            time = SummaryDayView.EventTime(startHour: 8, startMinute: 30, endHour: 10, endMinute: 0)
        }
    }
    private struct Event2: SummaryDayViewEvent {
        let time: SummaryDayView.EventTime
        let title = "test"
        let color = UIColor.redColor()
        let highlightedColor = UIColor.redColor().darkerColor().darkerColor()
        init() {
            time = SummaryDayView.EventTime(startHour: 9, startMinute: 30, endHour: 11, endMinute: 0)
        }
    }
    private struct Event3: SummaryDayViewEvent {
        let time: SummaryDayView.EventTime
        let title = "test"
        let color = UIColor.redColor()
        let highlightedColor = UIColor.redColor().darkerColor().darkerColor()
        init() {
            time = SummaryDayView.EventTime(startHour: 15, startMinute: 0, endHour: 16, endMinute: 20)
        }
    }
}