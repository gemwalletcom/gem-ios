// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keystore
import GemstonePrimitives
import Localization
import PrimitivesComponents

import enum Gemstone.PaymentType
import enum Gemstone.PaymentLinkType
import class Gemstone.SolanaPay
import NativeProviderService
import NodeService

typealias RecipientDataAction = ((RecipientData) -> Void)?

enum RecipientAddressType {
    case wallets
    case view
}

enum RecipientScanResult {
    case recipient(address: String, memo: String?, amount: String?)
    case paymentLink(link: PaymentLinkType)
    case transferData(TransferData)
}

class RecipientViewModel: ObservableObject {
    let wallet: Wallet
    let asset: Asset
    let type: RecipientAssetType
    let nodeService: NodeService

    private let keystore: any Keystore
    private let onRecipientDataAction: RecipientDataAction
    private let onTransferAction: TransferDataAction
    private let onPaymentLinkAction: PaymentLinkAction
    private let formatter = ValueFormatter(style: .full)
    
    init(
        wallet: Wallet,
        asset: Asset,
        keystore: any Keystore,
        nodeService: NodeService,
        type: RecipientAssetType,
        onRecipientDataAction: RecipientDataAction,
        onTransferAction: TransferDataAction,
        onPaymentLinkAction: PaymentLinkAction
    ) {
        self.wallet = wallet
        self.asset = asset
        self.keystore = keystore
        self.nodeService = nodeService
        self.type = type
        self.onRecipientDataAction = onRecipientDataAction
        self.onTransferAction = onTransferAction
        self.onPaymentLinkAction = onPaymentLinkAction
    }

    var tittle: String {
        return Localized.Transfer.Recipient.title
    }
    
    var recipientField: String { Localized.Transfer.Recipient.addressField }
    var memoField: String { Localized.Transfer.memo }

    var showMemo: Bool {
        asset.chain.isMemoSupported
    }
    
    var chain: Chain { asset.chain }

    func getRecipientData(name: NameRecord?, address: String, memo: String?, amount: String?) throws -> RecipientData {
        let recipient: Recipient = {
            if let result = name {
                return Recipient(name: result.name, address: result.address, memo: memo)
            }
            return Recipient(name: .none, address: address, memo: memo)
        }()
        try validateAddress(address: recipient.address)
        
        return RecipientData(
            recipient: recipient,
            amount: amount
        )
    }
    
    private func validateAddress(address: String) throws {
        guard asset.chain.isValidAddress(address) else {
            throw TransferError.invalidAddress(asset: asset)
        }
    }
    
    func getRecipient(by type: RecipientAddressType) -> [RecipientAddress] {
        switch type {
        case .wallets:
            return keystore.wallets
                .filter { ($0.type == .multicoin || $0.type == .single) && $0.id != wallet.id }
                .filter { $0.accounts.first(where: { $0.chain == asset.chain }) != nil }
                .map {
                    return RecipientAddress(
                        name: $0.name,
                        address: $0.accounts.first(where: { $0.chain == asset.chain })!.address
                    )
            }.compactMap { $0 }
        case .view:
            return keystore.wallets.filter { $0.type == .view }.filter { $0.accounts[0].chain == asset.chain}.map {
                return RecipientAddress(
                    name: $0.name,
                    address: $0.accounts[0].address
                )
            }
        }
    }
    
    //TODO: Add unit tests
    func getPaymentType(string: String) throws -> PaymentType {
        try PaymentURLDecoder.decode(string)
    }
    
    func getRecipientScanResult(paymentType: PaymentType) throws -> RecipientScanResult {
        switch paymentType {
        case .payment(let payment):
            if let amount = payment.amount,
               (showMemo ? ((payment.memo?.isEmpty) == nil) : true),
               asset.chain.isValidAddress(payment.address) {
                let transferType: TransferDataType = switch type {
                case .asset(let asset): .transfer(asset)
                case .nft(let asset): .transferNft(asset)
                }

                let value = try formatter.inputNumber(from: amount, decimals: asset.decimals.asInt)
                let data = TransferData(
                    type: transferType,
                    recipientData: RecipientData(
                        recipient: Recipient(
                            name: .none,
                            address: payment.address,
                            memo: payment.memo
                        ),
                        amount: .none
                    ),
                    value: value,
                    canChangeValue: false
                )
                return .transferData(data)
            }
            return .recipient(address: payment.address, memo: payment.memo, amount: payment.amount)
        case .paymentLink(let link):
            return .paymentLink(link: link)
        }
    }

    func getSolanaPayLabel(link: String) async throws -> PaymentLinkData {
        let solanaPay = SolanaPay(provider: NativeProvider(nodeProvider: nodeService))
        async let labelResult = try solanaPay.getLabel(link: link)
        async let txResult = try solanaPay.postAccount(link: link, account: wallet.account(for: .solana).address)
        let (label, tx) = try await (labelResult, txResult)
        return PaymentLinkData(label: label.label, logo: label.icon, chain: .solana, transaction: tx.transaction)
    }
}

// MARK: - Actions

extension RecipientViewModel {
    func onRecipientDataSelect(data: RecipientData) {
        switch type {
        case .asset(_):
            onRecipientDataAction?(data)
        case .nft(let asset):
            let data = TransferData(type: .transferNft(asset), recipientData: data, value: .zero, canChangeValue: false)
            onTransferDataSelect(data: data)
        }
    }
    
    func onTransferDataSelect(data: TransferData) {
        onTransferAction?(data)
    }

    func onPaymentLinkDataSelect(data: PaymentLinkData) {
        onPaymentLinkAction?(data)
    }
}

extension RecipientViewModel: Hashable {
    static func == (lhs: RecipientViewModel, rhs: RecipientViewModel) -> Bool {
        return lhs.wallet.id == rhs.wallet.id && lhs.asset == rhs.asset
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wallet.id)
    }
}
