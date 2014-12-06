//
//  SummaryDayTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/5/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SummaryDayTableViewCell: UITableViewCell, SummaryDayViewDelegate {
    
    weak var delegate: SummaryDayTableViewCellDelegate?

    @IBOutlet weak var summaryDayView: SummaryDayView!
    
    var viewModel: SummaryDayView.SummaryDayViewModel? {
        didSet {
            summaryDayView.viewModel = viewModel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        summaryDayView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Summary Day View Delegate
    func summaryDayView(summaryDayView: SummaryDayView, didSelectEvent event: SummaryDayViewEvent) {
        self.delegate?.summaryDayTableViewCell(self, didSelectEvent: event)
    }
}

protocol SummaryDayTableViewCellDelegate: class {
    func summaryDayTableViewCell(summaryDayTableViewCell: SummaryDayTableViewCell, didSelectEvent event: SummaryDayViewEvent)
}