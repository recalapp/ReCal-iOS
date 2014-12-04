//
//  SummaryDayViewLayoutAttributes.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 12/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public extension SummaryDayView {
    public enum Height {
        case Fill(oneHourHeight: CGFloat)
        case Fit
    }
    public enum SummarizationFactor {
        case Scale(Double)
        case Constant(CGFloat)
    }
}

public protocol SummaryDayViewLayoutAttributes {
    var expandedHeight: SummaryDayView.Height { get }
    var summarizedHeight: SummaryDayView.Height { get }
    var summarizationFactor: SummaryDayView.SummarizationFactor { get }
}