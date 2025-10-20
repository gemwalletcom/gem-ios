// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import SwapServiceTestKit
import Preferences
import BigInt
import Primitives
import Components
import Formatters
import struct Gemstone.SwapperQuote

@testable import Swap

@MainActor
struct SwapDetailsViewModelTests {
    @Test
    func swapEstimationText() {
        #expect(
            SwapDetailsViewModel
                .mock(selectedQuote: SwapperQuote.mock(etaInSeconds: nil).map()).swapEstimationText == nil
        )
        #expect(SwapDetailsViewModel.mock(selectedQuote: SwapperQuote.mock(etaInSeconds: 30).map()).swapEstimationText == nil)
        #expect(SwapDetailsViewModel.mock(selectedQuote: SwapperQuote.mock(etaInSeconds: 180).map()).swapEstimationText == "≈ 3 min")
    }
    
    @Test
    func switchRate() {
        let model = SwapDetailsViewModel.mock(selectedQuote: SwapperQuote.mock(toValue: "250000000000").map())
        
        #expect(model.rateText == "1 ETH ≈ 250,000.00 USDT")
        
        model.switchRateDirection()
        #expect(model.rateText == "1 USDT ≈ 0.000004 ETH")
    }
}

extension SwapDetailsViewModel {
    static func mock(selectedQuote: SwapQuote = SwapperQuote.mock().map()) -> SwapDetailsViewModel {
        SwapDetailsViewModel(
            state: .data([SwapperQuote.mock()]),
            fromAssetPrice: AssetPriceValue(asset: .mockEthereum(), price: .mock()),
            toAssetPrice: AssetPriceValue(asset: .mockEthereumUSDT(), price: .mock()),
            selectedQuote: selectedQuote,
            preferences: .mock(),
            swapProviderSelectAction: nil
        )
    }
}
