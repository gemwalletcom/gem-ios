// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit

struct ConfirmSwapDetailsViewModelTests {

    @Test
    func swap() {
        let model = ConfirmSwapDetailsViewModel(type: .swap(.mock(), .mock(), .mock()), metadata: nil)

        guard case .swapDetails = model.itemModel else { return }
        #expect(model.swapDetailsModel != nil)
    }

    @Test
    func transfer() {
        let model = ConfirmSwapDetailsViewModel(type: .transfer(.mock()), metadata: nil)
        #expect(model.swapDetailsModel == nil)
        guard case .empty = model.itemModel else {
            Issue.record("Expected .empty")
            return
        }
    }
}
