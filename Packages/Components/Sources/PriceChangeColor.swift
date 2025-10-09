// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct PriceChangeColor {
    public static func color(for value: Double) -> Color {
        switch value {
        case _ where value > 0:
            return Colors.green
        case _ where value < 0:
            return Colors.red
        default:
            return Colors.gray
        }
    }
}