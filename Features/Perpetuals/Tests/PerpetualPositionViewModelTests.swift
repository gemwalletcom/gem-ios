// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Style
import PerpetualsTestKit
@testable import Perpetuals

struct PerpetualPositionViewModelTests {
    
    @Test
    func leverageText() {
        #expect(createViewModel(position: PerpetualPosition.mock(leverage: 10)).leverageText == "10x")
    }
    
    @Test
    func directionText() {
        #expect(createViewModel(position: PerpetualPosition.mock(size: 100)).directionText == "Long")
        #expect(createViewModel(position: PerpetualPosition.mock(size: -100)).directionText == "Short")
    }
    
    @Test
    func positionTypeText() {
        #expect(createViewModel(position: PerpetualPosition.mock(size: 100, leverage: 5)).positionTypeText == "Long 5x")
    }
    
    @Test
    func marginText() {
        #expect(createViewModel(position: PerpetualPosition.mock(marginAmount: 1000)).marginText == "$1,000.00 (isolated)")
    }
    
    @Test
    func pnlText() {
        #expect(createViewModel(position: PerpetualPosition.mock(pnl: 500)).pnlText == "+$500.00")
        #expect(createViewModel(position: PerpetualPosition.mock(pnl: -200)).pnlText == "-$200.00")
    }
    
    @Test
    func pnlPercent() {
        #expect(createViewModel(position: PerpetualPosition.mock(marginAmount: 1000, pnl: 100)).pnlPercent == 0.1)
    }
    
    @Test
    func liquidationPriceText() {
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: 35000)).liquidationPriceText == "$35,000.00")
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: 0)).liquidationPriceText == nil)
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: nil)).liquidationPriceText == nil)
    }
    
    @Test
    func liquidationPriceColor() {
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: 40000, marginAmount: 100, pnl: 10)).liquidationPriceColor == .secondary)
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: 40000, marginAmount: 100, pnl: -20)).liquidationPriceColor == .secondary)
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: 40000, marginAmount: 100, pnl: -30)).liquidationPriceColor == Colors.orange)
        #expect(createViewModel(position: PerpetualPosition.mock(liquidationPrice: 40000, marginAmount: 100, pnl: -60)).liquidationPriceColor == Colors.red)
    }
}

private func createViewModel(position: PerpetualPosition) -> PerpetualPositionViewModel {
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
    return PerpetualPositionViewModel(data: positionData)
}
