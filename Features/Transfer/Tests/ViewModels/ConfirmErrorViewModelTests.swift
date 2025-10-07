// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit
import Validators

struct ConfirmErrorViewModelTests {

    @Test
    func error() {
        let error = AnyError("test error")
        let model = ConfirmErrorViewModel(state: .error(error), onSelectListError: { _ in })

        guard case .error(let title, let errorValue, _) = model.itemModel else { return }
        #expect(title == Localized.Errors.errorOccured)
        #expect(errorValue.localizedDescription == error.localizedDescription)
    }

    @Test
    func transferFailure() {
        let input = TransactionInputViewModel(
            data: .mock(),
            transactionData: .mock(),
            metaData: nil,
            transferAmount: .failure(.insufficientBalance(.mock()))
        )
        let model = ConfirmErrorViewModel(state: .data(input), onSelectListError: { _ in })

        guard case .error = model.itemModel else {
            Issue.record("Expected .error")
            return
        }
    }

    @Test
    func loaded() {
        let model = ConfirmErrorViewModel(state: .data(.mock()), onSelectListError: { _ in })
        guard case .empty = model.itemModel else {
            Issue.record("Expected .empty")
            return
        }
    }
}
