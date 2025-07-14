// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import SwapServiceTestKit
import Preferences
import BigInt
import Primitives
import Components
import Formatters
import struct Gemstone.SwapQuote

@testable import Swap

@MainActor
struct SwapDetailsViewModelTests {
    @Test
    func swapEstimationText() {
        #expect(SwapDetailsViewModel.mock(selectedQuote: .mock(etaInSeconds: nil)).swapEstimationText == nil)
        #expect(SwapDetailsViewModel.mock(selectedQuote: .mock(etaInSeconds: 30)).swapEstimationText == nil)
        #expect(SwapDetailsViewModel.mock(selectedQuote: .mock(etaInSeconds: 180)).swapEstimationText == "≈ 3 min")
    }
    
    @Test
    func switchRate() {
        let model = SwapDetailsViewModel.mock(selectedQuote: SwapQuote.mock(toValue: "250000000000"))
        
        #expect(model.rateText == "1 ETH ≈ 250,000.00 USDT")
        
        model.switchRateDirection()
        #expect(model.rateText == "1 USDT ≈ 0.000004 ETH")
    }
}

extension SwapDetailsViewModel {
    static func mock(selectedQuote: SwapQuote = .mock()) -> SwapDetailsViewModel {
        SwapDetailsViewModel(
            state: .data(true),
            fromAssetPrice: AssetPriceValue(asset: .mockEthereum(), price: .mock()),
            toAssetPrice: AssetPriceValue(asset: .mockEthereumUSDT(), price: .mock()),
            selectedQuote: selectedQuote,
            availableQuotes: [.mock()],
            preferences: .mock(),
            swapProviderSelectAction: nil
        )
    }
}
