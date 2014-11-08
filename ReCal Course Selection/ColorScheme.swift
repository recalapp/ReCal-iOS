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
//    private struct Static {
//        static var instance: ColorScheme?
//    }
//    
//    public class var currentColorScheme: ColorScheme {
//        get {
//            return Static.instance!
//        }
//        set {
//            Static.instance = newValue
//        }
//    }
    
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
    
    /// The blur effect to be used throughout the app
    public var blurEffect: UIVisualEffect {
        return UIBlurEffect(style: .Light)
    }
}

public class LightColorScheme: ColorScheme {
    /// The background color for views that do not display actual content
    public override var accessoryBackgroundColor: UIColor {
        return UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 206.0/255.0, alpha: 1)
    }
    
    /// Color used when one content is portrayed to be less important than the main content, such as a table view header
    public override var secondaryContentBackgroundColor: UIColor {
        return self.accessoryBackgroundColor.lighterColor()
    }
    
    /// The background color for views that do display content
    public override var contentBackgroundColor: UIColor {
        return UIColor.whiteColor()
    }
    
    /// The background color for selected items
    public override var selectedContentBackgroundColor: UIColor {
        return UIColor.lightGrayColor().lighterColor()
    }
    
    /// The text color for content
    public override var textColor: UIColor {
        return UIColor.darkTextColor()
    }
    
    /// Color to indicate that a text is a button, or is actionable
    public override var actionableTextColor: UIColor {
        return UIColor.blueColor()
    }
    
    /// The blur effect to be used throughout the app
    public override var blurEffect: UIVisualEffect {
        return UIBlurEffect(style: .Light)
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
    
    /// The blur effect to be used throughout the app
    public override var blurEffect: UIVisualEffect {
        return UIBlurEffect(style: .Dark)
    }
}