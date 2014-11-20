//
//  ColorScheme.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/7/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

public class ColorScheme {
    // MARK: - Singleton pattern
    
    public init(){
        
    }
    
    // MARK: - Colors
    /// The background color for views that do not display actual content
    public var accessoryBackgroundColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    public var secondaryContentBackgroundColor: UIColor {
        return UIColor.lightGrayColor()
    }
    
    /// The background color for views that do display content
    public var contentBackgroundColor: UIColor {
        return UIColor.lightGrayColor()
    }
    
    /// The background color for selected items
    public var selectedContentBackgroundColor: UIColor {
        return UIColor.blueColor()
    }
    
    /// The text color for content
    public var textColor: UIColor {
        return UIColor.darkTextColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    public var actionableTextColor: UIColor {
        return UIColor.blueColor()
    }
    
    /// Should be the color such that, if the default actionableTextColor were the background, this text would be readable
    public var alternateActionableTextColor: UIColor {
        return UIColor.lightTextColor()
    }
    
    /// The blur effect to be used throughout the app
    public var blurEffect: UIVisualEffect {
        return UIBlurEffect(style: .Light)
    }
    
    /// The color to indicate an alert.
    public var alertBackgroundColor: UIColor {
        return UIColor.redColor()
    }
    
    /// The text color for alert views.
    public var alertTextColor: UIColor {
        return UIColor.whiteColor()
    }
}

public class LightColorScheme: ColorScheme {
    /// The background color for views that do not display actual content
    public override var accessoryBackgroundColor: UIColor {
        return UIColor(red: 247/255.0, green: 247/255.0, blue: 252/255.0, alpha: 1)
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    public override var secondaryContentBackgroundColor: UIColor {
        return UIColor(red: 201/255.0, green: 201/255.0, blue: 206/255.0, alpha: 0.95)
    }
    
    /// The background color for views that do display content
    public override var contentBackgroundColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// The background color for selected items
    public override var selectedContentBackgroundColor: UIColor {
        return UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
    }
    
    /// The text color for content
    public override var textColor: UIColor {
        return UIColor.darkTextColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    public override var actionableTextColor: UIColor {
        return UIColor(red: 0/255.0, green: 107/255.0, blue: 255/255.0, alpha: 1.0)
    }
    
    /// Should be the color such that, if the default actionableTextColor were the background, this text would be readable
    public override var alternateActionableTextColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// The blur effect to be used throughout the app
    public override var blurEffect: UIVisualEffect {
        return UIBlurEffect(style: .ExtraLight)
    }
    
    /// The color to indicate an alert.
    public override var alertBackgroundColor: UIColor {
        return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    }
    
    /// The text color for alert views.
    public override var alertTextColor: UIColor {
        return UIColor.lightTextColor()
    }
}

public class DarkColorScheme: ColorScheme {
    /// The background color for views that do not display actual content
    public override var accessoryBackgroundColor: UIColor {
        return UIColor.lightBlackGrayColor()
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    public override var secondaryContentBackgroundColor: UIColor {
        return UIColor.lightBlackGrayColor().lighterColor()
    }
    
    /// The background color for views that do display content
    public override var contentBackgroundColor: UIColor {
        return UIColor.darkBlackGrayColor().lighterColor()
    }
    
    /// The background color for selected items
    public override var selectedContentBackgroundColor: UIColor {
        return UIColor.darkBlackGrayColor()
    }
    
    /// The text color for content
    public override var textColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    public override var actionableTextColor: UIColor {
        return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1)
    }
    
    /// Should be the color such that, if the default actionableTextColor were the background, this text would be readable
    public override var alternateActionableTextColor: UIColor {
        return UIColor.lightTextColor()
    }
    
    /// The blur effect to be used throughout the app
    public override var blurEffect: UIVisualEffect {
        return UIBlurEffect(style: .Dark)
    }
    
    /// The color to indicate an alert.
    public override var alertBackgroundColor: UIColor {
        return UIColor(red: 204.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    /// The text color for alert views.
    public override var alertTextColor: UIColor {
        return UIColor.lightTextColor()
    }
}