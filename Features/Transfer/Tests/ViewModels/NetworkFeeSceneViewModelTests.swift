// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import Transfer

@MainActor
struct NetworkFeeSceneViewModelTests {
    @Test
    func showFeeRatesSelector() {
        let model = NetworkFeeSceneViewModel(
            chain: .ethereum,
            priority: .normal
        )
        
        model.update(rates: [.defaultRate()])
        #expect(model.showFeeRatesSelector == false)
        
        model.update(rates: [.defaultRate(), .defaultRate()])
        #expect(model.showFeeRatesSelector)
    }
}
