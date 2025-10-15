// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt

@testable import PrimitivesComponents

@MainActor
struct NetworkFeeSceneViewModelTests {
    @Test
    func showFeeRatesSelector() {
        let model = NetworkFeeSceneViewModel(
            chain: .ethereum,
            priority: .normal
        )

        model.update(rates: [.defaultRate()])
        #expect(model.showFeeRates == false)

        model.update(rates: [.defaultRate(), .defaultRate()])
        #expect(model.showFeeRates)
    }
    
    @Test
    func valueMatchesSelectedFeeRateEthereumValueText() {
        let model = NetworkFeeSceneViewModel(
            chain: .ethereum,
            priority: .normal
        )

        model.update(rates: [.defaultRate()])

        #expect(model.selectedFeeRateViewModel?.valueText == "0.000000001 gwei")
    }
    
    @Test
    func valueMatchesSelectedFeeRateSolanaValueText() {
        let model = NetworkFeeSceneViewModel(
            chain: .solana,
            priority: .normal
        )

        model.update(rates: [FeeRate(priority: .normal, gasPriceType: .eip1559(gasPrice: 5000, priorityFee: 100000))])

        #expect(model.selectedFeeRateViewModel?.valueText == "0.000105 SOL")
    }
    
    @Test
    func valueMatchesSelectedFeeRateBitcoinValueText() {
        let model = NetworkFeeSceneViewModel(
            chain: .bitcoin,
            priority: .normal
        )

        model.update(rates: [.defaultRate()])

        #expect(model.selectedFeeRateViewModel?.valueText == "1 sat/vB")
    }
}
