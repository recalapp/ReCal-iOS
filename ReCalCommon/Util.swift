//
//  Util.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

func ASSERT_MAIN_THREAD() {
    assert(NSThread.isMainThread(), "This method must be called on the main thread");
}

extension Array {
    func find(isIncludedElement: T -> Bool) -> NSIndexSet {
        var indexes = NSMutableIndexSet()
        for (i, element) in enumerate(self) {
            if isIncludedElement(element) {
                indexes.addIndex(i)
            }
        }
        return indexes
    }
}

public extension NSLayoutConstraint {
    public class func layoutConstraintsForChildView(childView: UIView, inParentView parentView: UIView, withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        let leadingConstraint = NSLayoutConstraint(item: childView, attribute: .Leading, relatedBy: .Equal, toItem: parentView, attribute: .Left, multiplier: 1, constant: insets.left)
        let trailingConstraint = NSLayoutConstraint(item: childView, attribute: .Trailing, relatedBy: .Equal, toItem: parentView, attribute: .Right, multiplier: 1, constant: -insets.right)
        let topConstraint = NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: parentView, attribute: .Top, multiplier: 1, constant: insets.top)
        let bottomConstraint = NSLayoutConstraint(item: childView, attribute: .Bottom, relatedBy: .Equal, toItem: parentView, attribute: .Bottom, multiplier: 1, constant: -insets.bottom)
        return [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
    }
}

public extension String {
    public func contains(other: String, caseSensitive: Bool = true) -> Bool {
        return self.rangeOfString(other, options: caseSensitive ? NSStringCompareOptions.allZeros : NSStringCompareOptions.CaseInsensitiveSearch) != nil
    }
    public func isNumeric() -> Bool {
        return self.toInt() != nil
    }
}

public extension UIColor {
    public func darkerColor() -> UIColor {
        return self.colorWithBrightness(scale: 0.75)
    }
    public func lighterColor() -> UIColor {
        return self.colorWithBrightness(scale: 1.3)
    }
    public func colorWithBrightness(#scale: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0
        var saturation: CGFloat = 1.0
        var brightness: CGFloat = 1.0
        var alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if brightness == 0.0 {
            brightness = 0.2
        }
        return UIColor(hue: hue, saturation: saturation, brightness: min(brightness * scale, 1.0), alpha: alpha)
    }
    public class func darkBlackGrayColor() -> UIColor {
        return UIColor(red: 32.0/255.0, green: 32.0/255.0, blue: 29.0/255.0, alpha: 1.0)
    }
    public class func lightBlackGrayColor() -> UIColor {
        return UIColor(red: 47.0/255.0, green: 47.0/255.0, blue: 42.0/255.0, alpha: 1.0)
    }
    
    public class func fromHexString(var hexString: NSString) -> UIColor? {
        let colorComponentFromString: (NSString, Int, Int) -> CGFloat = { (colorString, start, length) in
            let subString = colorString.substringWithRange(NSMakeRange(start, length))
            let fullHex = length == 2 ? subString : "\(subString)\(subString)"
            var hexComponent: UInt32 = 0
            NSScanner(string: fullHex).scanHexInt(&hexComponent)
            return CGFloat(hexComponent) / 255.0
        }
        hexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        var alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat
        switch hexString.length {
        case 3: // #RGB
            alpha = 1.0
            red = colorComponentFromString(hexString, 0, 1)
            green = colorComponentFromString(hexString, 1, 1)
            blue = colorComponentFromString(hexString, 2, 1)
        case 4: // #ARGB
            alpha = colorComponentFromString(hexString, 0, 1)
            red = colorComponentFromString(hexString, 1, 1)
            green = colorComponentFromString(hexString, 2, 1)
            blue = colorComponentFromString(hexString, 3, 1)
        case 6: // #RRGGBB
            alpha = 1.0
            red = colorComponentFromString(hexString, 0, 2)
            green = colorComponentFromString(hexString, 1, 2)
            blue = colorComponentFromString(hexString, 2, 2)
        case 8: // #AARRGGBB
            alpha = colorComponentFromString(hexString, 0, 2)
            red = colorComponentFromString(hexString, 1, 2)
            green = colorComponentFromString(hexString, 2, 2)
            blue = colorComponentFromString(hexString, 3, 2)
        default:
            assertionFailure("Invalid color string")
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public func arrayFindIndexesOfElement<T: Equatable>(#array: [T], #element: T) -> [Int] {
    var indexes = [Int]()
    for (i, elementToCheck) in enumerate(array) {
        if element == elementToCheck {
            indexes.append(i)
        }
    }
    return indexes
}

public func arrayContainsElement<T: Equatable>(#array: [T], #element: T) -> Bool {
    return array.filter { $0 == element }.count > 0
}

public func arraysContainSameElements<T: Equatable>(array1: [T], array2: [T]) -> Bool {
    return array1.count == array2.count && array1.reduce(true, combine: { (old, value) in
        return old && arrayContainsElement(array: array2, element: value)
    })
}

public func arrayFlatten<T>(array: [[T]]) -> [T] {
    return array.reduce([], combine: {(flattened, item) in flattened + item })
}

public extension String {
    public func pluralize() -> String {
        let last = self.substringFromIndex(self.endIndex.predecessor())
        if last == "s" {
            return self + "es"
        } else {
            return self + "s"
        }
    }
}
