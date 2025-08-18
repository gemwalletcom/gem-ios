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
import AddressNameService
import AddressNameServiceTestKit
import Store

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
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .swap(.mock(), .mock(), .mock()))).title == Localized.Wallet.swap)
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .tokenApprove(.mock(), .mock()))).title == Localized.Wallet.swap)
    }
    
    @Test
    func senderTitle() async {
        #expect(ConfirmTransferSceneViewModel.mock().senderTitle == Localized.Wallet.title)
    }
    
    @Test
    func recipientAddress() async {
        let address = "0x1234567890123456789012345678901234567890"
        let model = ConfirmTransferSceneViewModel.mock(data: .mock(
            type: .transfer(.mock()),
            recipient: RecipientData.mock(recipient: .mock(address: address))
        ))

        #expect(model.recipientAddressViewModel.account.address == address)
        #expect(model.recipientAddressViewModel.account.name == nil)
    }
    
    @Test
    func recipientName() async {
        let db = DB.mockAssets()
        let address = "bc1qml9s2f9k8wc0882x63lyplzp97srzg2c39fyaw"
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(
                type: .transfer(.mock()),
                recipient: RecipientData.mock(recipient: .mock(address: address))
            ),
            addressNameService: .mock(addressStore: .mockAddresses(db: db))
        )

        #expect(model.recipientAddressViewModel.account.address == address)
        #expect(model.recipientAddressViewModel.account.name == "Bitcoin")
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
    
    @Test
    func listSections() async {
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .transfer(.mockEthereum()))
        )
        let sections = model.listSections
        
        #expect(sections.count == 2)
        #expect(sections[0].type == .main)
        #expect(sections[1].type == .fee)
        
        let mainSection = sections[0]
        #expect(mainSection.items.contains(where: { item in
            if case .common(.detail) = item { return true }
            return false
        }))
        #expect(mainSection.items.contains(where: { item in
            if case .common(.detail(title: _, subtitle: _, image: _, contextMenu: _)) = item { return true }
            return false
        }))
    }
    
    @Test
    func listSectionsWithApp() async {
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .generic(
                asset: .mock(),
                metadata: .mock(name: "TestApp", url: "https://test.com"),
                extra: .mock()
            ))
        )
        let sections = model.listSections
        
        #expect(sections.count >= 2)
        #expect(sections[0].type == .main)
        
        let hasApp = sections[0].items.contains(where: { item in
            if case .common = item { return true }
            return false
        })
        #expect(hasApp)
    }
    
    @Test
    func listSectionsWithRecipient() async {
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(
                type: .transfer(.mockEthereum()),
                recipient: .mock(recipient: .mock(address: "0x1234567890123456789012345678901234567890"))
            )
        )
        let sections = model.listSections
        
        let hasAddress = sections[0].items.contains(where: { item in
            if case .address = item { return true }
            return false
        })
        #expect(hasAddress)
    }
    
    @Test
    func listSectionsWithMemo() async {
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(
                type: .transfer(.mock(id: .mockSolana())),
                recipient: .mock(recipient: .mock(memo: "Test memo"))
            )
        )
        let sections = model.listSections
        
        let hasMemo = sections[0].items.contains(where: { item in
            if case .memo = item { return true }
            return false
        })
        #expect(hasMemo)
    }
    
    @Test
    func listSectionsWithSwap() async {
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .swap(.mockEthereum(), .mockEthereumUSDT(), .mock()))
        )
        let sections = model.listSections
        
        let hasSwapDetails = sections[0].items.contains(where: { item in
            if case .swapDetails = item { return true }
            return false
        })
        #expect(hasSwapDetails)
    }
    
    @Test
    func listSectionsFeeSectionAlwaysPresent() async {
        let models = [
            ConfirmTransferSceneViewModel.mock(data: .mock(type: .transfer(.mockEthereum()))),
            ConfirmTransferSceneViewModel.mock(data: .mock(type: .swap(.mockEthereum(), .mockEthereumUSDT(), .mock()))),
            ConfirmTransferSceneViewModel.mock(data: .mock(type: .tokenApprove(.mockEthereumUSDT(), .mock())))
        ]
        
        for model in models {
            let sections = model.listSections
            #expect(sections.contains(where: { $0.type == .fee }))
        }
    }
}

private extension ConfirmTransferSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        data: TransferData = .mock(),
        addressNameService: AddressNameService = .mock(addressStore: .mock())
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
                addressNameService: addressNameService,
                chain: data.chain
            ),
            onComplete: {}
        )
    }
}