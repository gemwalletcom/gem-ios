// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit

struct ConfirmButtonViewModelTests {

    @Test
    func loaded() {
        let model = ConfirmButtonViewModel(state: .data(TransactionInputViewModel.mock()), icon: nil, onAction: {})
        #expect(model.title == Localized.Transfer.confirm)
    }

    @Test
    func error() {
        let model = ConfirmButtonViewModel(state: .error(AnyError("test")), icon: nil, onAction: {})
        #expect(model.title == Localized.Common.tryAgain)
    }
}

