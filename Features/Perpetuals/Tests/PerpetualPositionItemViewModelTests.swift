// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import Style
@testable import Perpetuals

struct PerpetualPositionItemViewModelTests {
    
    @Test
    func name() {
        #expect(PerpetualPositionItemViewModel(position: .mock(), perpetualViewModel: PerpetualViewModel(perpetual: .mock(name: "BTC-USD"))).name == "BTC-USD")
    }
    
    @Test
    func perpetualProperty() {
        #expect(PerpetualPositionItemViewModel(position: .mock(), perpetualViewModel: PerpetualViewModel(perpetual: .mock(id: "BTC-USD"))).perpetual.id == "BTC-USD")
    }
}