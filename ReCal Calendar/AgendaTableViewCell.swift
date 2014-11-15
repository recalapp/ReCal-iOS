//
//  AgendaTableViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/10/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class AgendaTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    lazy private var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var viewModel: AgendaTableViewCellViewModel? {
        didSet {
            self.refresh()
        }
    }
    
    @IBOutlet weak var colorTagView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Settings.currentSettings.colorScheme.contentBackgroundColor
        self.titleLabel.textColor = Settings.currentSettings.colorScheme.textColor
        self.courseLabel.textColor = Settings.currentSettings.colorScheme.textColor
        self.timeLabel.textColor = Settings.currentSettings.colorScheme.textColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func refresh() {
        if let viewModel = self.viewModel {
            self.titleLabel.text = viewModel.title
            self.courseLabel.text = viewModel.subtitle
            self.timeLabel.text = viewModel.rightTitle
            self.colorTagView.backgroundColor = viewModel.colorTag
        }
    }
}

protocol AgendaTableViewCellViewModel {
    var title: String { get }
    var subtitle: String { get }
    var rightTitle: String { get }
    var colorTag: UIColor { get }
}
