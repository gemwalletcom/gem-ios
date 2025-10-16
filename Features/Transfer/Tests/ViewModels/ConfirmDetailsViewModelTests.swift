// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit

struct ConfirmDetailsViewModelTests {

    @Test
    func swap() {
        let model = ConfirmDetailsViewModel(type: .swap(.mock(), .mock(), .mock()), metadata: nil)

        guard case .swapDetails = model.itemModel else {
            Issue.record("Expected .swapDetails")
            return
        }
    }

    @Test
    func transfer() {
        let model = ConfirmDetailsViewModel(type: .transfer(.mock()), metadata: nil)

        guard case .empty = model.itemModel else {
            Issue.record("Expected .empty")
            return
        }
    }

    @Test
    func perpetual() {
        let model = ConfirmDetailsViewModel(type: .perpetual(.mock(), .open(.mock())), metadata: nil)

        guard case .perpetualDetails = model.itemModel else {
            Issue.record("Expected .perpetualDetails")
            return
        }
    }
}
