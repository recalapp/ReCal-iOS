//
//  ColorScheme.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/7/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class ColorScheme {
    // MARK: - Singleton pattern
    private struct Static {
        static var instance: ColorScheme?
    }
    class var currentColorScheme: ColorScheme {
        get {
            return Static.instance!
        }
        set {
            Static.instance = newValue
        }
    }
    
    // MARK: - Colors
    /// The background color for views that do not display actual content
    var accessoryBackgroundColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    var secondaryContentBackgroundColor: UIColor {
        return UIColor.lightGrayColor()
    }
    
    /// The background color for views that do display content
    var contentBackgroundColor: UIColor {
        return UIColor.lightGrayColor()
    }
    
    /// The background color for selected items
    var selectedContentBackgroundColor: UIColor {
        return UIColor.blueColor()
    }
    
    /// The text color for content
    var textColor: UIColor {
        return UIColor.darkTextColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    var actionableTextColor: UIColor {
        return UIColor.blueColor()
    }
}

class LightColorScheme: ColorScheme {
    /// The background color for views that do not display actual content
    override var accessoryBackgroundColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    override var secondaryContentBackgroundColor: UIColor {
        return UIColor.lightGrayColor().lighterColor()
    }
    
    /// The background color for views that do display content
    override var contentBackgroundColor: UIColor {
        return UIColor.lightGrayColor()
    }
    
    /// The background color for selected items
    override var selectedContentBackgroundColor: UIColor {
        return UIColor.darkGrayColor()
    }
    
    /// The text color for content
    override var textColor: UIColor {
        return UIColor.darkTextColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    override var actionableTextColor: UIColor {
        return UIColor.blueColor()
    }
}

class DarkColorScheme: ColorScheme {
    /// The background color for views that do not display actual content
    override var accessoryBackgroundColor: UIColor {
        return UIColor.lightBlackGrayColor()
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    override var secondaryContentBackgroundColor: UIColor {
        return UIColor.lightBlackGrayColor().lighterColor()
    }
    
    /// The background color for views that do display content
    override var contentBackgroundColor: UIColor {
        return UIColor.darkBlackGrayColor().lighterColor()
    }
    
    /// The background color for selected items
    override var selectedContentBackgroundColor: UIColor {
        return UIColor.darkBlackGrayColor()
    }
    
    /// The text color for content
    override var textColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    override var actionableTextColor: UIColor {
        return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1)
    }
}