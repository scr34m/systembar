//
//  NSColor+fromHex.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 23..
//

// https://github.com/pketh/NSColor-fromHex-Swift/blob/master/NSColor%2BfromHex.swift

import Cocoa

extension NSColor {
    class func fromHex(hexColor: String) -> NSColor {
        var hex = String()
        if hexColor.hasPrefix("#") {
            hex = String(hexColor[hexColor.index(hexColor.startIndex, offsetBy: 1)...])
        } else {
            hex = hexColor
        }

        func hexToCGFloat(color: String) -> CGFloat {
            var result: CUnsignedInt = 0
            let scanner: Scanner = Scanner(string: color)
            scanner.scanHexInt32(&result)
            let colorValue: CGFloat = CGFloat(result)
            return colorValue / 255
        }

        let redComponent = hexToCGFloat(color: String(hex[hex.index(hex.startIndex, offsetBy: 0)...hex.index(hex.startIndex, offsetBy: 1)])),
        greenComponent = hexToCGFloat(color: String(hex[hex.index(hex.startIndex, offsetBy: 2)...hex.index(hex.startIndex, offsetBy: 3)])),
        blueComponent = hexToCGFloat(color: String(hex[hex.index(hex.startIndex, offsetBy: 4)...hex.index(hex.startIndex, offsetBy: 5)]))

        let color = NSColor(calibratedRed: redComponent, green: greenComponent, blue: blueComponent, alpha: 1)

        return color
    }
}

