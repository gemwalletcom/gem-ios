// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
import Foundation
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit

struct ConfirmAppViewModelTests {

    @Test
    func generic() {
        let metadata = WalletConnectionSessionAppMetadata.mock()
        let model = ConfirmAppViewModel(type: .generic(asset: .mock(), metadata: metadata, extra: .mock()))

        guard case .app(let item) = model.itemModel else { return }
        #expect(item.title == Localized.WalletConnect.app)
        #expect(item.subtitle != nil)
        #expect(model.websiteURL == URL(string: metadata.url))
        #expect(model.websiteTitle == Localized.Settings.website)
    }

    @Test
    func transfer() {
        guard case .empty = ConfirmAppViewModel(type: .transfer(.mock())).itemModel else { return }
    }

    @Test
    func deposit() {
        guard case .empty = ConfirmAppViewModel(type: .deposit(.mock())).itemModel else { return }
    }

    @Test
    func withdrawal() {
        guard case .empty = ConfirmAppViewModel(type: .withdrawal(.mock())).itemModel else { return }
    }

    @Test
    func transferNft() {
        guard case .empty = ConfirmAppViewModel(type: .transferNft(.mock())).itemModel else { return }
    }

    @Test
    func swap() {
        guard case .empty = ConfirmAppViewModel(type: .swap(.mock(), .mock(), .mock())).itemModel else { return }
    }

    @Test
    func tokenApprove() {
        guard case .empty = ConfirmAppViewModel(type: .tokenApprove(.mock(), .mock())).itemModel else { return }
    }

    @Test
    func stake() {
        guard case .empty = ConfirmAppViewModel(type: .stake(.mock(), .stake(.mock()))).itemModel else { return }
    }

    @Test
    func account() {
        guard case .empty = ConfirmAppViewModel(type: .account(.mock(), .activate)).itemModel else { return }
    }

    @Test
    func perpetual() {
        guard case .empty = ConfirmAppViewModel(type: .perpetual(.mock(), .open(.mock()))).itemModel else { return }
    }
}