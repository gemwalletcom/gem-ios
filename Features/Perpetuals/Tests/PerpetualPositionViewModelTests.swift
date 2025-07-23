// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import Style
@testable import Perpetuals

struct PerpetualPositionViewModelTests {
    
    @Test
    func leverageText() {
        #expect(PerpetualPositionViewModel(position: .mock(leverage: 10)).leverageText == "10x")
    }
    
    @Test
    func directionText() {
        #expect(PerpetualPositionViewModel(position: .mock(size: 100)).directionText == "Long")
        #expect(PerpetualPositionViewModel(position: .mock(size: -100)).directionText == "Short")
    }
    
    @Test
    func positionTypeText() {
        #expect(PerpetualPositionViewModel(position: .mock(size: 100, leverage: 5)).positionTypeText == "Long 5x")
    }
    
    @Test
    func marginText() {
        #expect(PerpetualPositionViewModel(position: .mock(marginAmount: 1000)).marginText == "$1K")
    }
    
    @Test
    func pnlText() {
        #expect(PerpetualPositionViewModel(position: .mock(pnl: 500)).pnlText == "+$500")
        #expect(PerpetualPositionViewModel(position: .mock(pnl: -200)).pnlText == "-$200")
    }
    
    @Test
    func pnlPercent() {
        #expect(PerpetualPositionViewModel(position: .mock(marginAmount: 1000, pnl: 100)).pnlPercent == 10.0)
    }
    
    @Test
    func liquidationPriceText() {
        #expect(PerpetualPositionViewModel(position: .mock(liquidationPrice: 35000)).liquidationPriceText == "$35K")
        #expect(PerpetualPositionViewModel(position: .mock(liquidationPrice: 0)).liquidationPriceText == "--")
        #expect(PerpetualPositionViewModel(position: .mock(liquidationPrice: nil)).liquidationPriceText == "--")
    }
    
    @Test
    func liquidationPriceColor() {
        #expect(PerpetualPositionViewModel(position: .mock(marginAmount: 100, pnl: 10, liquidationPrice: 40000)).liquidationPriceColor == .secondary)
        #expect(PerpetualPositionViewModel(position: .mock(marginAmount: 100, pnl: -20, liquidationPrice: 40000)).liquidationPriceColor == .secondary)
        #expect(PerpetualPositionViewModel(position: .mock(marginAmount: 100, pnl: -30, liquidationPrice: 40000)).liquidationPriceColor == Colors.orange)
        #expect(PerpetualPositionViewModel(position: .mock(marginAmount: 100, pnl: -60, liquidationPrice: 40000)).liquidationPriceColor == Colors.red)
    }
    
}
