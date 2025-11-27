// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Transfer
import Primitives
import PrimitivesTestKit
import TransferTestKit
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
import ActivityServiceTestKit
import Store
import BigInt
import Components

@MainActor
struct ConfirmTransferSceneViewModelTests {

    @Test
    func itemModelReturnsNonEmpty() {
        let model = ConfirmTransferSceneViewModel.mock()

        verifyNonEmpty(model.itemModel(for: .header))
        verifyNonEmpty(model.itemModel(for: .sender))
        verifyNonEmpty(model.itemModel(for: .network))
        verifyNonEmpty(model.itemModel(for: .recipient))
        verifyNonEmpty(model.itemModel(for: .networkFee))
    }
    
    @Test
    func headerItemModel() async {
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .transfer(.mockEthereum()))
        )
        let headerItem = model.itemModel(for: .header) as? ConfirmHeaderViewModel

        if case .header = headerItem?.itemModel {
            // Expected header item
        } else {
            Issue.record("Expected header item model")
        }
    }

    @Test
    func appItemModel() async {
        let model = ConfirmTransferSceneViewModel.mock()
        let appItem = model.itemModel(for: .app) as? ConfirmAppViewModel

        if case .empty = appItem?.itemModel {
            // Expected empty for non-generic transfer
        } else {
            Issue.record("Expected empty app item model")
        }

        let modelWithWebsite = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .generic(asset: .mock(), metadata: .mock(name: "Gem Wallet", url: "https://example.com"), extra: .mock()))
        )
        let appItemWithWebsite = modelWithWebsite.itemModel(for: .app) as? ConfirmAppViewModel

        if case .app(let listItem) = appItemWithWebsite?.itemModel {
            #expect(listItem.subtitle == "Gem Wallet (example.com)")
        } else {
            Issue.record("Expected app item model")
        }
    }
    
    @Test
    func title() async {
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .transfer(.mock()))).title == Localized.Transfer.Send.title)
        //#expect(ConfirmTransferViewModel.mock(data: .mock(type: .transferNft(.mock()))).title == Localized.Transfer.Send.title)
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .swap(.mock(), .mock(), .mock()))).title == Localized.Wallet.swap)
        #expect(ConfirmTransferSceneViewModel.mock(data: .mock(type: .tokenApprove(.mock(), .mock()))).title == Localized.Wallet.swap)
    }
    
    @Test
    func senderItemModel() async {
        let model = ConfirmTransferSceneViewModel.mock()
        let senderItem = model.itemModel(for: .sender) as? ConfirmSenderViewModel

        if case .sender(let listItem) = senderItem?.itemModel {
            #expect(listItem.title == Localized.Wallet.title)
        } else {
            Issue.record("Expected sender item model")
        }
    }
    
    @Test
    func recipientItemModel() async {
        let address = "0x1234567890123456789012345678901234567890"
        let model = ConfirmTransferSceneViewModel.mock(data: .mock(
            type: .transfer(.mock()),
            recipient: RecipientData.mock(recipient: .mock(address: address))
        ))
        let recipientItem = model.itemModel(for: .recipient) as? ConfirmRecipientViewModel

        if case .recipient(let addressViewModel) = recipientItem?.itemModel {
            #expect(addressViewModel.account.address == address)
            #expect(addressViewModel.account.name == nil)
        } else {
            Issue.record("Expected recipient item model")
        }
    }
    
    @Test
    func recipientNameItemModel() async {
        let db = DB.mockAssets()
        let address = "bc1qml9s2f9k8wc0882x63lyplzp97srzg2c39fyaw"
        let model = ConfirmTransferSceneViewModel.mock(
            data: .mock(
                type: .transfer(.mock()),
                recipient: RecipientData.mock(recipient: .mock(address: address))
            ),
            addressNameService: .mock(addressStore: .mockAddresses(db: db))
        )
        let recipientItem = model.itemModel(for: .recipient) as? ConfirmRecipientViewModel

        if case .recipient(let addressViewModel) = recipientItem?.itemModel {
            #expect(addressViewModel.account.address == address)
            #expect(addressViewModel.account.name == "Bitcoin")
        } else {
            Issue.record("Expected recipient item model")
        }
    }
    
    @Test
    func networkItemModel() async {
        let ethModel = ConfirmTransferSceneViewModel.mock(data: .mock(type: .transfer(.mockEthereum())))
        let ethNetworkItem = ethModel.itemModel(for: .network) as? ConfirmNetworkViewModel

        if case .network(let listItem) = ethNetworkItem?.itemModel {
            #expect(listItem.subtitle == "Ethereum")
        } else {
            Issue.record("Expected network item model for ETH")
        }

        let usdtModel = ConfirmTransferSceneViewModel.mock(data: .mock(type: .transfer(.mockEthereumUSDT())))
        let usdtNetworkItem = usdtModel.itemModel(for: .network) as? ConfirmNetworkViewModel

        if case .network(let listItem) = usdtNetworkItem?.itemModel {
            #expect(listItem.subtitle == "Ethereum (ERC20)")
        } else {
            Issue.record("Expected network item model for USDT")
        }

        let genericEthModel = ConfirmTransferSceneViewModel.mock(data: .mock(type: .generic(asset: .mockEthereum(), metadata: .mock(), extra: .mock())))
        let genericEthNetworkItem = genericEthModel.itemModel(for: .network) as? ConfirmNetworkViewModel

        if case .network(let listItem) = genericEthNetworkItem?.itemModel {
            #expect(listItem.subtitle == "Ethereum")
        } else {
            Issue.record("Expected network item model for generic ETH")
        }

        let genericUsdtModel = ConfirmTransferSceneViewModel.mock(data: .mock(type: .generic(asset: .mockEthereumUSDT(), metadata: .mock(), extra: .mock())))
        let genericUsdtNetworkItem = genericUsdtModel.itemModel(for: .network) as? ConfirmNetworkViewModel

        if case .network(let listItem) = genericUsdtNetworkItem?.itemModel {
            #expect(listItem.subtitle == "Ethereum")
        } else {
            Issue.record("Expected network item model for generic USDT")
        }
    }

    @Test
    func networkFeeItemModel() async {
        let model = ConfirmTransferSceneViewModel.mock()

        model.state = .error(AnyError("test"))
        let errorFeeItem = model.itemModel(for: .networkFee) as? ConfirmNetworkFeeViewModel

        if case .networkFee(let listItem, _) = errorFeeItem?.itemModel {
            #expect(listItem.subtitle == "-")
            #expect(listItem.subtitleExtra == nil)
        } else {
            Issue.record("Expected network fee item model for error state")
        }

        model.feeModel.update(value: "0.001 ETH", fiatValue: "$2.50")
        model.state = .data(TransactionInputViewModel.mock())
        let feeWithFiatItem = model.itemModel(for: .networkFee) as? ConfirmNetworkFeeViewModel

        if case .networkFee(let listItem, _) = feeWithFiatItem?.itemModel {
            #expect(listItem.subtitle == "$2.50")
            #expect(listItem.subtitleExtra == nil)
        } else {
            Issue.record("Expected network fee item model with fiat")
        }

        model.feeModel.update(value: "0.001 ETH", fiatValue: nil)
        let feeNoFiatItem = model.itemModel(for: .networkFee) as? ConfirmNetworkFeeViewModel

        if case .networkFee(let listItem, _) = feeNoFiatItem?.itemModel {
            #expect(listItem.subtitle == "0.001 ETH")
            #expect(listItem.subtitleExtra == nil)
        } else {
            Issue.record("Expected network fee item model without fiat")
        }
    }

    @Test
    func memoItemModel() async {
        let modelWithMemo = ConfirmTransferSceneViewModel.mock(
            data: .mock(
                type: .transfer(.mock(id: .mockSolana())),
                recipient: RecipientData.mock(recipient: .mock(memo: "Test memo"))
            )
        )
        let memoItem = modelWithMemo.itemModel(for: .memo) as? ConfirmMemoViewModel

        if case .memo(let listItem) = memoItem?.itemModel {
            #expect(listItem.title == Localized.Transfer.memo)
            #expect(listItem.subtitle == "Test memo")
        } else {
            Issue.record("Expected memo item model")
        }

        let modelNoMemo = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .transfer(.mockEthereum()))
        )
        let noMemoItem = modelNoMemo.itemModel(for: .memo) as? ConfirmMemoViewModel

        if case .empty = noMemoItem?.itemModel {
            // Expected empty for non-memo chain
        } else {
            Issue.record("Expected empty for non-memo chain")
        }
    }

    @Test
    func swapDetailsItemModel() async {
        let swapModel = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .swap(.mockEthereum(), .mockEthereumUSDT(), .mock()))
        )
        let swapItem = swapModel.itemModel(for: .details) as? ConfirmDetailsViewModel

        if case .swapDetails = swapItem?.itemModel {
            // Expected swap details
        } else {
            Issue.record("Expected swap details item model")
        }

        let transferModel = ConfirmTransferSceneViewModel.mock(
            data: .mock(type: .transfer(.mock()))
        )
        let transferSwapItem = transferModel.itemModel(for: .details) as? ConfirmDetailsViewModel

        if case .empty = transferSwapItem?.itemModel {
            // Expected empty for non-swap
        } else {
            Issue.record("Expected empty for non-swap transaction")
        }
    }

    @Test
    func errorItemModel() async {
        let model = ConfirmTransferSceneViewModel.mock()
        model.state = .error(AnyError("Test error"))

        let errorItem = model.itemModel(for: .error) as? ConfirmErrorViewModel

        if case .error(let title, _, _) = errorItem?.itemModel {
            #expect(title == Localized.Errors.errorOccured)
        } else if case .empty = errorItem?.itemModel {
            // Can be empty when no error
        } else {
            Issue.record("Expected error or empty item model")
        }
    }

    @Test
    func sectionsStructure() {
        let model = ConfirmTransferSceneViewModel.mock()
        let sections = model.sections

        #expect(sections.count == 4)
        #expect(sections[0].id == "header")
        #expect(sections[1].id == "details")
        #expect(sections[2].id == "fee")
        #expect(sections[3].id == "error")

        #expect(sections[0].values == [.header])
        #expect(sections[1].values == [.app, .network, .sender, .recipient, .memo, .details])
        #expect(sections[2].values == [.networkFee])
        #expect(sections[3].values == [.error])
    }

    @Test
    func scanTransactionMaliciousError() {
        let model = ConfirmTransferSceneViewModel.mock()
        model.onSelectListError(error: ScanTransactionError.malicious)

        guard case .info(.maliciousTransaction) = model.isPresentingSheet else {
            Issue.record("Expected maliciousTransaction sheet")
            return
        }
    }

    @Test
    func scanTransactionMemoRequiredError() {
        let model = ConfirmTransferSceneViewModel.mock()
        model.onSelectListError(error: ScanTransactionError.memoRequired(symbol: "BTC"))

        guard case .info(.memoRequired(let symbol)) = model.isPresentingSheet else {
            Issue.record("Expected memoRequired sheet")
            return
        }
        #expect(symbol == "BTC")
    }

    private func verifyNonEmpty(_ model: any ItemModelProvidable<ConfirmTransferItemModel>) {
        if case .empty = model.itemModel {
            Issue.record("Expected non-empty model")
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
                activityService: .mock(),
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
