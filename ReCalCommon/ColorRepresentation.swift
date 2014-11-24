//
//  ColorRepresentation.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/24/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import Foundation

public class ColorRepresentation : NSObject, NSCoding, NSCopying, Hashable {
    private struct CodingKeys {
        static let NormalizedHexString = "ColorHexNormalizedHexString"
    }
    public let normalizedHexString: String
    public lazy var alphaComponent: CGFloat = {
        return self.colorComponentFromString(self.normalizedHexString, start: 0, length: 2)
    }()
    public lazy var redComponent: CGFloat = {
        return self.colorComponentFromString(self.normalizedHexString, start: 2, length: 2)
    }()
    public lazy var greenComponent: CGFloat = {
        return self.colorComponentFromString(self.normalizedHexString, start: 4, length: 2)
        }()
    public lazy var blueComponent: CGFloat = {
        return self.colorComponentFromString(self.normalizedHexString, start: 6, length: 2)
    }()
    
    public init(var hexString: String) {
        hexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        
        switch countElements(hexString) {
        case 3: // #RGB
            self.normalizedHexString = "FF\(doubleStringChar(hexString))"
        case 4: // #ARGB
            self.normalizedHexString = doubleStringChar(hexString)
        case 6: // #RRGGBB
            self.normalizedHexString = "FF\(hexString)"
        case 8:
            self.normalizedHexString = hexString
        default:
            self.normalizedHexString = "FFFFFFFF"
            assertionFailure("Invalid hex string")
        }
    }
    
    private func colorComponentFromString(colorString: NSString, start: Int, length: Int) -> CGFloat {
        let subString = colorString.substringWithRange(NSMakeRange(start, length))
        let fullHex = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt32 = 0
        NSScanner(string: fullHex).scanHexInt(&hexComponent)
        return CGFloat(hexComponent) / 255.0
    }

    required public init(coder aDecoder: NSCoder) {
        self.normalizedHexString = aDecoder.decodeObjectForKey(CodingKeys.NormalizedHexString) as String
    }
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.normalizedHexString, forKey: CodingKeys.NormalizedHexString)
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ColorRepresentation(hexString: self.normalizedHexString)
        return copy
    }
    
    public override var hashValue: Int {
        return self.normalizedHexString.hashValue
    }
}

public func == (lhs: ColorRepresentation, rhs: ColorRepresentation)-> Bool {
    return lhs.normalizedHexString == rhs.normalizedHexString
}

private func doubleStringChar(input: String) -> String {
    if countElements(input) == 0 {
        return ""
    }
    let firstChar = input.substringToIndex(input.startIndex.successor())
    let rest = input.substringFromIndex(input.startIndex.successor())
    return "\(firstChar)\(firstChar)\(doubleStringChar(rest))"
}