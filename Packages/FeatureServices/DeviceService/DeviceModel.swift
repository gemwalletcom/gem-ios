// Copyright (c). Gem Wallet. All rights reserved.

import UIKit
import Foundation

extension UIDevice {
    
    public var osName: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    
    @MainActor
    var machineIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    /// Device model name mapping from machine identifier to readable name
    /// Source: https://gist.githubusercontent.com/adamawolf/3048717/raw/5b5afb4cf0d2d17ef268a7547dd532fdbbec8327/Apple_mobile_device_types.txt
    @MainActor
    public var modelName: String {
        switch machineIdentifier {
        case "i386", "x86_64", "arm64": "iPhone Simulator"
        case "iPhone10,1", "iPhone10,4": "iPhone 8"
        case "iPhone10,2", "iPhone10,5": "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": "iPhone X"
        case "iPhone11,2": "iPhone XS"
        case "iPhone11,4", "iPhone11,6": "iPhone XS Max"
        case "iPhone11,8": "iPhone XR"
        case "iPhone12,1": "iPhone 11"
        case "iPhone12,3": "iPhone 11 Pro"
        case "iPhone12,5": "iPhone 11 Pro Max"
        case "iPhone12,8": "iPhone SE 2nd Gen"
        case "iPhone13,1": "iPhone 12 Mini"
        case "iPhone13,2": "iPhone 12"
        case "iPhone13,3": "iPhone 12 Pro"
        case "iPhone13,4": "iPhone 12 Pro Max"
        case "iPhone14,2": "iPhone 13 Pro"
        case "iPhone14,3": "iPhone 13 Pro Max"
        case "iPhone14,4": "iPhone 13 Mini"
        case "iPhone14,5": "iPhone 13"
        case "iPhone14,6": "iPhone SE 3rd Gen"
        case "iPhone14,7": "iPhone 14"
        case "iPhone14,8": "iPhone 14 Plus"
        case "iPhone15,2": "iPhone 14 Pro"
        case "iPhone15,3": "iPhone 14 Pro Max"
        case "iPhone15,4": "iPhone 15"
        case "iPhone15,5": "iPhone 15 Plus"
        case "iPhone16,1": "iPhone 15 Pro"
        case "iPhone16,2": "iPhone 15 Pro Max"
        case "iPhone17,1": "iPhone 16 Pro"
        case "iPhone17,2": "iPhone 16 Pro Max"
        case "iPhone17,3": "iPhone 16"
        case "iPhone17,4": "iPhone 16 Plus"
        case "iPhone17,5": "iPhone 16e"
        case "iPhone18,1": "iPhone 17 Pro"
        case "iPhone18,2": "iPhone 17 Pro Max"
        case "iPhone18,3": "iPhone 17"
        case "iPhone18,4": "iPhone Air"
        case "iPad6,7", "iPad6,8": "iPad Pro 12.9-inch"
        case "iPad6,11", "iPad6,12": "iPad 5th Gen"
        case "iPad7,1", "iPad7,2": "iPad Pro 12.9-inch 2nd Gen"
        case "iPad7,3", "iPad7,4": "iPad Pro 10.5-inch"
        case "iPad7,5", "iPad7,6": "iPad 6th Gen"
        case "iPad7,11", "iPad7,12": "iPad 7th Gen"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": "iPad Pro 11-inch 3rd Gen"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": "iPad Pro 12.9-inch 3rd Gen"
        case "iPad8,9", "iPad8,10": "iPad Pro 11-inch 4th Gen"
        case "iPad8,11", "iPad8,12": "iPad Pro 12.9-inch 4th Gen"
        case "iPad11,1", "iPad11,2": "iPad mini 5th Gen"
        case "iPad11,3", "iPad11,4": "iPad Air 3rd Gen"
        case "iPad11,6", "iPad11,7": "iPad 8th Gen"
        case "iPad12,1", "iPad12,2": "iPad 9th Gen"
        case "iPad13,1", "iPad13,2": "iPad Air 4th Gen"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": "iPad Pro 11-inch 5th Gen"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": "iPad Pro 12.9-inch 5th Gen"
        case "iPad13,16", "iPad13,17": "iPad Air 5th Gen"
        case "iPad13,18", "iPad13,19": "iPad 10th Gen"
        case "iPad14,1", "iPad14,2": "iPad mini 6th Gen"
        case "iPad14,3", "iPad14,4": "iPad Pro 11-inch 4th Gen"
        case "iPad14,5", "iPad14,6": "iPad Pro 12.9-inch 6th Gen"
        case "iPad14,8", "iPad14,9": "iPad Air 11-inch 6th Gen"
        case "iPad14,10", "iPad14,11": "iPad Air 13-inch 6th Gen"
        case "iPad15,3", "iPad15,4": "iPad Air 11-inch 7th Gen"
        case "iPad15,5", "iPad15,6": "iPad Air 13-inch 7th Gen"
        case "iPad15,7", "iPad15,8": "iPad 11th Gen"
        case "iPad16,1", "iPad16,2": "iPad mini 7th Gen"
        case "iPad16,3", "iPad16,4": "iPad Pro 11-inch 5th Gen"
        case "iPad16,5", "iPad16,6": "iPad Pro 12.9-inch 7th Gen"
        default: machineIdentifier
        }
    }
}
