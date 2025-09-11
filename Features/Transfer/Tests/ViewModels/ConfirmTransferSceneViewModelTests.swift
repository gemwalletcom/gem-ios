// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
import Primitives
import PrimitivesTestKit
import PrimitivesComponents
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
import BigInt

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
    func networkFeeValue() async {
        let model = ConfirmTransferSceneViewModel.mock()

        model.state = .error(AnyError("test"))
        #expect(model.networkFeeValue == "-")
        #expect(model.networkFeeFiatValue == nil)

        model.feeModel.update(value: "0.001 ETH", fiatValue: "$2.50")
        model.state = .data(TransactionInputViewModel.mock())
        #expect(model.networkFeeValue == "$2.50")
        #expect(model.networkFeeFiatValue == nil)
        
        model.feeModel.update(value: "0.001 ETH", fiatValue: nil)
        #expect(model.networkFeeValue == "0.001 ETH")
        #expect(model.networkFeeFiatValue == nil)
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

private extension TransactionInputViewModel {
    static func mock(
        validation: TransferAmountValidation = TransferAmountValidation.success(
            TransferAmount(value: BigInt(100), networkFee: BigInt(21000), useMaxAmount: false)
        )
    ) -> TransactionInputViewModel {
        TransactionInputViewModel(
            data: .mock(),
            transactionData: nil,
            metaData: nil,
            transferAmount: validation
        )
    }
}
