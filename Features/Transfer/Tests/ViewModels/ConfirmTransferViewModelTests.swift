// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
import Primitives
import PrimitivesTestKit
import WalletsService
import WalletsServiceTestKit
import BlockchainTestKit
import ScanService
import ScanServiceTestKit
import SwapService
import SwapServiceTestKit
import KeystoreTestKit
import Localization
import Gemstone
import Preferences
import PreferencesTestKit
import GemAPI

@MainActor
struct ConfirmTransferViewModelTests {
    
    @Test
    func appText() async {
        let model = ConfirmTransferViewModel.mock()
        #expect(model.appText == Localized.Errors.unknown)
        
        let modelWithWebsite = ConfirmTransferViewModel.mock(
            data: .mock(type: .generic(asset: .mock(), metadata: .mock(name: "Gem Wallet", url: "https://example.com"), extra: .mock()))
        )
        #expect(modelWithWebsite.appText == "Gem Wallet (example.com)")
    }
    
    @Test
    func title() async {
        #expect(ConfirmTransferViewModel.mock(data: .mock(type: .transfer(.mock()))).title == Localized.Transfer.Send.title)
        #expect(ConfirmTransferViewModel.mock(data: .mock(type: .transferNft(.mock()))).title == Localized.Transfer.Send.title)
        #expect(ConfirmTransferViewModel.mock(data: .mock(type: .swap(.mock(), .mock(), .mock(), nil))).title == Localized.Wallet.swap)
        #expect(ConfirmTransferViewModel.mock(data: .mock(type: .tokenApprove(.mock(), .mock()))).title == Localized.Wallet.swap)
    }
    
    @Test
    func senderTitle() async {
        #expect(ConfirmTransferViewModel.mock().senderTitle == Localized.Wallet.title)
    }
}

private extension ConfirmTransferViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        data: TransferData = .mock()
    ) -> ConfirmTransferViewModel {
        ConfirmTransferViewModel(
            wallet: wallet,
            data: data,
            keystore: KeystoreMock(),
            chainService: ChainServiceMock(),
            scanService: .mock(),
            swapService: .mock(),
            walletsService: .mock(),
            swapDataProvider: .mock(),
            onComplete: {}
        )
    }
}
