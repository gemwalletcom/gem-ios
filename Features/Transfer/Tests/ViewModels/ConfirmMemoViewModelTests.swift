// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit

struct ConfirmMemoViewModelTests {

    @Test
    func cosmos() {
        let asset = Asset.mock(id: AssetId(chain: .cosmos, tokenId: nil))
        let memo = "test memo"
        let model = ConfirmMemoViewModel(type: .transfer(asset), recipientData: .mock(recipient: .mock(memo: memo)))

        guard case .memo(let item) = model.itemModel else { return }
        #expect(item.title == Localized.Transfer.memo)
        #expect(item.subtitle == memo)
    }

    @Test
    func stellar() {
        let asset = Asset.mock(id: AssetId(chain: .stellar, tokenId: nil))
        let memo = "stellar memo"
        let model = ConfirmMemoViewModel(type: .deposit(asset), recipientData: .mock(recipient: .mock(memo: memo)))

        guard case .memo(let item) = model.itemModel else { return }
        #expect(item.title == Localized.Transfer.memo)
        #expect(item.subtitle == memo)
    }

    @Test
    func ton() {
        let asset = Asset.mock(id: AssetId(chain: .ton, tokenId: nil))
        let memo = "ton comment"
        let model = ConfirmMemoViewModel(type: .withdrawal(asset), recipientData: .mock(recipient: .mock(memo: memo)))

        guard case .memo(let item) = model.itemModel else { return }
        #expect(item.title == Localized.Transfer.memo)
        #expect(item.subtitle == memo)
    }

    @Test
    func bitcoin() {
        let model = ConfirmMemoViewModel(type: .transfer(.mock()), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func transferNft() {
        let model = ConfirmMemoViewModel(type: .transferNft(.mock()), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func swap() {
        let model = ConfirmMemoViewModel(type: .swap(.mock(), .mock(), .mock()), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func tokenApprove() {
        let model = ConfirmMemoViewModel(type: .tokenApprove(.mock(), .mock()), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func stake() {
        let model = ConfirmMemoViewModel(type: .stake(.mock(), .stake(.mock())), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func account() {
        let model = ConfirmMemoViewModel(type: .account(.mock(), .activate), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func perpetual() {
        let model = ConfirmMemoViewModel(type: .perpetual(.mock(), .open(.mock())), recipientData: .mock())
        guard case .empty = model.itemModel else { return }
    }

    @Test
    func generic() {
        let model = ConfirmMemoViewModel(
            type: .generic(asset: .mock(), metadata: .mock(), extra: .mock()),
            recipientData: .mock()
        )
        guard case .empty = model.itemModel else { return }
    }
}