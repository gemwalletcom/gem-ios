// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization

struct ChartLineViewModel: Identifiable {
    let line: ChartLine

    var id: String { line.id }
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
        case .stopLoss: Colors.red
        case .entry: Colors.blue
        case .liquidation: Colors.orange
        }
    }

    var lineStyle: StrokeStyle {
        switch line.type {
        case .takeProfit, .stopLoss: StrokeStyle(lineWidth: 1, dash: [6, 4])
        case .entry: StrokeStyle(lineWidth: 1.5)
        case .liquidation: StrokeStyle(lineWidth: 1, dash: [2, 2])
        }
    }
}
