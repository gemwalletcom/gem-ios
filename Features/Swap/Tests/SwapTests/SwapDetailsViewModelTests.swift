// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import SwapServiceTestKit
import Preferences
import BigInt
import Primitives
import Components
import struct Gemstone.SwapQuote

@testable import Swap

@MainActor
struct SwapDetailsViewModelTests {
    @Test
    func swapEstimationText() {
        let model = SwapDetailsViewModel.mock(selectedQuote: .mock(etaInSeconds: nil))
        #expect(model.swapEstimationText == nil)
        
        let modelShort = SwapDetailsViewModel.mock(selectedQuote: .mock(etaInSeconds: 30))
        #expect(modelShort.swapEstimationText == nil)
        
        let modelLong = SwapDetailsViewModel.mock(selectedQuote: .mock(etaInSeconds: 180))
        #expect(modelLong.swapEstimationText == "≈ 3 min")
    }
    
    @Test
    func switchRate() {
        let model = SwapDetailsViewModel.mock(selectedQuote: .mock(toValue: "250000000000"))
        
        #expect(model.rateText == "1 ETH ≈ 250,000.00 USDT")
        
        model.switchRateDirection()
        #expect(model.rateText == "1 USDT ≈ 0.000004 ETH")
    }
}

extension SwapDetailsViewModel {
    static func mock(
        state: StateViewType<Bool> = .data(true),
        fromAsset: AssetData = .mock(asset: .mockEthereum()),
        toAsset: AssetData = .mock(asset: .mockEthereumUSDT()),
        selectedQuote: SwapQuote = .mock(),
        availableQuotes: [SwapQuote] = [.mock()],
        preferences: Preferences = .standard,
        swapProviderSelectAction: @escaping (SwapProviderItem) -> Void = { _ in }
    ) -> SwapDetailsViewModel {
        SwapDetailsViewModel(
            state: state,
            fromAsset: fromAsset,
            toAsset: toAsset,
            selectedQuote: selectedQuote,
            availableQuotes: availableQuotes,
            preferences: preferences,
            swapProviderSelectAction: swapProviderSelectAction
        )
    }
}