// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
import Primitives
import PrimitivesTestKit
import WalletsServiceTestKit
import BlockchainTestKit
import ScanServiceTestKit
import KeystoreTestKit
import BalanceServiceTestKit
import PriceServiceTestKit
import TransactionServiceTestKit  
import NodeServiceTestKit
import Localization

@MainActor
struct ConfirmTransferSceneViewModelTests {
    
    @Test
    func appText() async {
        #expect(ConfirmTransferSceneViewModel.mock().appText == .none)
        
        let modelWithWebsite = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .generic(asset: .mock(), metadata: .mock(name: "Gem Wallet", url: "https://example.com"), extra: .mock()))
        )
        #expect(modelWithWebsite.appText == "Gem Wallet (example.com)")
    }
    
    @Test
    func title() async {
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .transfer(.mock()))).title == Localized.Transfer.Send.title)
        //#expect(ConfirmTransferViewModel.mock(data: .mock(type: .transferNft(.mock()))).title == Localized.Transfer.Send.title)
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .swap(.mock(), .mock(), .mock()))).title == Localized.Wallet.swap)
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .tokenApprove(.mock(), .mock()))).title == Localized.Wallet.swap)
    }
    
    @Test
    func senderTitle() async {
        #expect(ConfirmTransferSceneViewModel.mock().senderTitle == Localized.Wallet.title)
    }
    
    @Test
    func networkText() async {
        #expect(
            ConfirmTransferSceneViewModel
                .mock(data: .mock(type: .transfer(.mockEthereum()))
            ).networkText == "Ethereum"
        )
        #expect(
            ConfirmTransferSceneViewModel
                .mock(data: .mock(type: .transfer(.mockEthereumUSDT()))
            ).networkText == "Ethereum (ERC20)"
        )
        
        #expect(
            ConfirmTransferSceneViewModel
                .mock(data: .mock(type: .generic(asset: .mockEthereum(), metadata: .mock(), extra: .mock()))
            ).networkText == "Ethereum"
        )
        #expect(
            ConfirmTransferSceneViewModel
                .mock( data: .mock(type: .generic(asset: .mockEthereumUSDT(), metadata: .mock(), extra: .mock()) )
            ).networkText == "Ethereum"
        )
    }
}

private extension ConfirmTransferSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        data: TransferData = .mock()
    ) -> ConfirmTransferSceneViewModel {
        ConfirmTransferSceneViewModel(
            wallet: wallet,
            data: data,
            confirmService: ConfirmServiceFactory.create(
                keystore: KeystoreMock(),
                nodeService: .mock(),
                walletsService: .mock(),
                scanService: .mock(),
                balanceService: .mock(),
                priceService: .mock(),
                transactionService: .mock(),
                chain: data.chain
            ),
            onComplete: {}
        )
    }
}
