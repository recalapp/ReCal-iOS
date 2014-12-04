//
//  SummaryDayView.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class SummaryDayView: UIView {

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public var state: State = .Summarized
    public var viewModel: SummaryDayViewModel?
    public var layoutAttributes: SummaryDayViewLayoutAttributes = DefaultLayoutAttributes()
    
    public enum State {
        case Summarized
        case Expanded
    }
    public struct DefaultLayoutAttributes: SummaryDayViewLayoutAttributes {
        public let expandedHeight: Height = .Fill(oneHourHeight:100)
        public let summarizedHeight: Height = .Fit
        public let summarizationFactor: SummarizationFactor = .Scale(0.2)
    }
}
