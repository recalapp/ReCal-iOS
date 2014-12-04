//
//  EventCollectionViewCell.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/18/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
class EventCollectionViewCell: UICollectionViewCell {
    
    var viewModel: EventCellViewModel? {
        didSet {
            self.updateText()
            self.updateColor()
        }
    }
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var colorTagView: UIView!
    
    override var selected: Bool {
        didSet {
            self.updateColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateColor()
    }
    
    private func updateText() {
        if let viewModel = self.viewModel {
            self.eventTitleLabel.text = viewModel.title
        } else {
            self.eventTitleLabel.text = ""
        }
    }
    
    private func updateColor() {
        if let viewModel = self.viewModel {
            self.colorTagView.backgroundColor = viewModel.highlightedColor
            if self.selected {
                self.backgroundColor = viewModel.highlightedColor
                self.eventTitleLabel.textColor = viewModel.normalColor
            } else {
                self.backgroundColor = viewModel.normalColor
                self.eventTitleLabel.textColor = viewModel.highlightedColor
            }
        }
    }
}

protocol EventCellViewModel {
    var highlightedColor: UIColor { get }
    var normalColor: UIColor { get }
    var title: String { get }
}