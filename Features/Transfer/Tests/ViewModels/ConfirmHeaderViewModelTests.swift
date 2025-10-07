// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit

struct ConfirmHeaderViewModelTests {

    @Test
    func transfer() {
        let input = TransactionInputViewModel(data: .mock(type: .transfer(.mock())), transactionData: nil, metaData: nil, transferAmount: nil)
        let model = ConfirmHeaderViewModel(inputModel: input, metadata: nil, data: .mock())

        guard case .header(let item) = model.itemModel else { return }
        guard case .amount = item.headerType else { return }
        #expect(item.showClearHeader == true)
    }

    @Test
    func swap() {
        let input = TransactionInputViewModel(data: .mock(type: .swap(.mock(), .mock(), .mock())), transactionData: nil, metaData: nil, transferAmount: nil)
        let model = ConfirmHeaderViewModel(inputModel: input, metadata: nil, data: .mock())

        guard case .header(let item) = model.itemModel else { return }
        guard case .swap = item.headerType else { return }
        #expect(item.showClearHeader == false)
    }

    @Test
    func nft() {
        let input = TransactionInputViewModel(data: .mock(type: .transferNft(.mock())), transactionData: nil, metaData: nil, transferAmount: nil)
        let model = ConfirmHeaderViewModel(inputModel: input, metadata: nil, data: .mock())

        guard case .header(let item) = model.itemModel else { return }
        guard case .nft = item.headerType else { return }
        #expect(item.showClearHeader == true)
    }
}