//
//  SummaryDayTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SummaryDayTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryDayView: SummaryDayView!
    
    var viewModel: SummaryDayView.SummaryDayViewModel? {
        didSet {
            summaryDayView.viewModel = viewModel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}