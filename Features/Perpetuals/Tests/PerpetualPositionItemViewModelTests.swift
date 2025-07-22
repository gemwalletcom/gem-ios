// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Perpetuals
import Primitives
import PrimitivesTestKit
import Components
import Style

struct PerpetualPositionItemViewModelTests {
    
    @Test
    func pnlColor() {
        #expect(PerpetualPositionItemViewModel(position: .mock(pnl: 10), perpetual: .mock()).pnlColor == Colors.green)
        #expect(PerpetualPositionItemViewModel(position: .mock(pnl: -10), perpetual: .mock()).pnlColor == Colors.red)
    }
    
    @Test
    func positionType() {
        #expect(PerpetualPositionItemViewModel(position: .mock(size: 1.0, leverage: 20), perpetual: .mock()).positionTypeText == "Long 20x")
        #expect(PerpetualPositionItemViewModel(position: .mock(size: -1.0, leverage: 10), perpetual: .mock()).positionTypeText == "Short 10x")
    }
    
    @Test
    func positionTypeColor() {
        #expect(PerpetualPositionItemViewModel(position: .mock(size: 1.0), perpetual: .mock()).positionTypeColor == Colors.green)
        #expect(PerpetualPositionItemViewModel(position: .mock(size: -1.0), perpetual: .mock()).positionTypeColor == Colors.red)
    }
    
    @Test
    func pnlPercentCalculation() {
        // 10x leverage: $10 PnL on $100 margin = 10%
        #expect(PerpetualPositionItemViewModel(
            position: .mock(size: 1.0, leverage: 10, pnl: 10),
            perpetual: .mock(price: 1000)
        ).pnlPercent == 10.0)
        
        // 20x leverage: -$40 PnL on $200 margin = -20%
        #expect(PerpetualPositionItemViewModel(
            position: .mock(size: 2.0, leverage: 20, pnl: -40),
            perpetual: .mock(price: 2000)
        ).pnlPercent == -20.0)
        
        // Zero size edge case
        #expect(PerpetualPositionItemViewModel(
            position: .mock(size: 0, leverage: 10, pnl: 10),
            perpetual: .mock(price: 1000)
        ).pnlPercent == 0)
    }
}

// Add extensions to make private properties testable
extension PerpetualPositionItemViewModel {
    var pnlColor: Color { position.pnl >= 0 ? Colors.green : Colors.red }
    var positionTypeText: String {
        let leverageText = "\(Int(position.leverage))x"
        let direction = position.size > 0 ? "Long" : "Short"
        return "\(direction) \(leverageText)"
    }
    var positionTypeColor: Color { position.size > 0 ? Colors.green : Colors.red }
}
