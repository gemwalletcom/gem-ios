// Copyright (c). Gem Wallet. All rights reserved.

import UIKit

public enum DeviceSize {
    case small
    case medium
    case large

    @MainActor
    public static var current: DeviceSize {
        switch UIScreen.main.bounds.height {
        case ...667:  .small // iPhone SE-size
        case 668..<896: .medium // Regular iPhone (e.g., iPhone 11, 12, 13, 14, 15)
        case 896..<1000: .large // Pro Max iPhones (e.g., iPhone 11/12/13/14/15 Pro Max)
        case 1000...1200: .medium // Smaller iPads or iPad Air
        case 1200...: .large // Large iPad Pro (11" or 12.9")
        default: .medium
        }
    }
}
