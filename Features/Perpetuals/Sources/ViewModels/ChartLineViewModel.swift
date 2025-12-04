// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Primitives

struct ChartLineViewModel: Identifiable {
    let line: ChartLine

    var id: String { "\(line.type)_\(line.price)" }
    var price: Double { line.price }

    var label: String {
        switch line.type {
        case .takeProfit: Localized.Charts.takeProfit
        case .stopLoss: Localized.Charts.stopLoss
        case .entry: Localized.Charts.entry
        case .liquidation: Localized.Charts.liquidation
        }
    }

    var color: Color {
        switch line.type {
        case .takeProfit: Colors.green
        case .stopLoss: Colors.orange
        case .entry: Colors.gray
        case .liquidation: Colors.red
        }
    }

    var lineStyle: StrokeStyle {
        StrokeStyle(lineWidth: 1, dash: [4, 3])
    }
}
