// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Style
import PerpetualsTestKit
@testable import Perpetuals

struct PerpetualPositionViewModelTests {
    
    @Test
    func leverageText() {
        #expect(createPositionViewModel(.mock(leverage: 10)).leverageText == "10x")
    }
    
    @Test
    func directionText() {
        #expect(createPositionViewModel(.mock(size: 100)).directionText == "Long")
        #expect(createPositionViewModel(.mock(size: -100)).directionText == "Short")
    }
    
    @Test
    func positionTypeText() {
        #expect(createPositionViewModel(.mock(size: 100, leverage: 5)).positionTypeText == "LONG 5x")
    }
    
    @Test
    func marginText() {
        #expect(createPositionViewModel(.mock(marginAmount: 1000)).marginText == "$1,000.00 (isolated)")
    }
    
    @Test
    func pnlWithPercentText() {
        #expect(createPositionViewModel(.mock(marginAmount: 1000, pnl: 500)).pnlWithPercentText == "+$500.00 (+50.00%)")
        #expect(createPositionViewModel(.mock(marginAmount: 1000, pnl: -200)).pnlWithPercentText == "-$200.00 (-20.00%)")
    }

    @Test
    func pnlPercent() {
        #expect(createPositionViewModel(.mock(marginAmount: 1000, pnl: 100)).pnlPercent == 10.0)
    }
    
    @Test
    func entryPriceText() {
        #expect(createPositionViewModel(.mock(entryPrice: 42000)).entryPriceText == "$42,000.00")
        #expect(createPositionViewModel(.mock(entryPrice: 0)).entryPriceText == nil)
        #expect(createPositionViewModel(.mock(entryPrice: nil)).entryPriceText == nil)
    }
    
    @Test
    func liquidationPriceText() {
        #expect(createPositionViewModel(.mock(liquidationPrice: 35000)).liquidationPriceText == "$35,000.00")
        #expect(createPositionViewModel(.mock(liquidationPrice: 0)).liquidationPriceText == nil)
        #expect(createPositionViewModel(.mock(liquidationPrice: nil)).liquidationPriceText == nil)
    }
    
    @Test
    func positionTypeColor() {
        #expect(createPositionViewModel(.mock(direction: .short)).positionTypeColor == Colors.red)
        #expect(createPositionViewModel(.mock(direction: .long)).positionTypeColor == Colors.green)
    }
    
//    @Test
//    func liquidationPriceColor() {
//        // Long position: entry $2.00, liquidation $1.50
//        #expect(createPositionViewModel(.mock(entryPrice: 2.00, currencyPrice: 2.00, liquidationPrice: 1.50)).liquidationPriceColor == Colors.secondaryText)
//        #expect(createPositionViewModel(.mock(entryPrice: 2.00, currencyPrice: 1.75, liquidationPrice: 1.50)).liquidationPriceColor == Colors.orange)
//        #expect(createPositionViewModel(.mock(entryPrice: 2.00, currencyPrice: 1.599, liquidationPrice: 1.50)).liquidationPriceColor == Colors.red)
//        
//        // Short position: entry $1.27, liquidation $1.91
//        #expect(createPositionViewModel(.mock(entryPrice: 1.27, currencyPrice: 1.27, liquidationPrice: 1.91)).liquidationPriceColor == Colors.secondaryText)
//        #expect(createPositionViewModel(.mock(entryPrice: 1.27, currencyPrice: 1.59, liquidationPrice: 1.91)).liquidationPriceColor == Colors.orange)
//        #expect(createPositionViewModel(.mock(entryPrice: 1.27, currencyPrice: 1.782, liquidationPrice: 1.91)).liquidationPriceColor == Colors.red)
//    }
}

private func createPositionViewModel(_ position: PerpetualPosition) -> PerpetualPositionViewModel {
    let asset = Asset(
        id: AssetId(chain: .bitcoin, tokenId: nil),
        name: "Bitcoin",
        symbol: "BTC",
        decimals: 8,
        type: .native
    )
    let positionData = PerpetualPositionData(
        perpetual: Perpetual.mock(),
        asset: asset,
        position: position
    )
    return PerpetualPositionViewModel(positionData)
}
