// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct ChartLineViewModel: Identifiable {
    let line: ChartLine

    var id: String { line.id }
    var price: Double { line.price }

    var label: String {
        switch line.type {
        case .takeProfit: "TP"
        case .stopLoss: "SL"
        case .entry: "Entry"
        case .liquidation: "Liq"
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
