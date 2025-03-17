// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keystore
import GemstonePrimitives
import Localization
import PrimitivesComponents
import Store
import Contacts
import Components

typealias RecipientDataAction = ((RecipientData) -> Void)?

enum RecipientAddressType {
    case wallets
    case view
}

enum RecipientScanResult {
    case recipient(address: String, memo: String?, amount: String?)
    case transferData(TransferData)
}

@Observable
class RecipientViewModel {
    let wallet: Wallet
    let asset: Asset
    let type: RecipientAssetType
    var address: String = ""
    var memo: String = ""
    var amount: String = ""
    var addressListRequest: ContactAddressInfoListRequest

    private let keystore: any Keystore
    private let onRecipientDataAction: RecipientDataAction
    private let onTransferAction: TransferDataAction
    private let formatter = ValueFormatter(style: .full)
    
    init(
        wallet: Wallet,
        asset: Asset,
        keystore: any Keystore,
        type: RecipientAssetType,
        onRecipientDataAction: RecipientDataAction,
        onTransferAction: TransferDataAction
    ) {
        self.wallet = wallet
        self.asset = asset
        self.keystore = keystore
        self.type = type
        self.onRecipientDataAction = onRecipientDataAction
        self.onTransferAction = onTransferAction
        
        self.addressListRequest = ContactAddressInfoListRequest(
            chain: asset.chain
        )
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
    
    func buildListItemViews(addresses: [ContactAddressData]) -> [ContactListViewItem<ContactAddressData>] {
        addresses
            .map {
                let memo = $0.address.memo
                return ContactListViewItem<ContactAddressData>(
                    id: $0.id,
                    name: $0.contact.name,
                    address: $0.address.address,
                    memo: $0.address.memo,
                    object: $0
                )
        }
    }
    
    //TODO: Add unit tests
    func getPaymentScanResult(string: String) throws -> PaymentScanResult {
        let payment = try PaymentURLDecoder.decode(string)

        return PaymentScanResult(
            address: payment.address,
            amount: payment.amount,
            memo: payment.memo
        )
    }
    
    func getRecipientScanResult(payment: PaymentScanResult) throws -> RecipientScanResult {
        if
            let amount = payment.amount,
            (showMemo ? ((payment.memo?.isEmpty) == nil) : true),
            asset.chain.isValidAddress(payment.address)
        {
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
    }
}

// MARK: - Actions

extension RecipientViewModel {
    func onRecipientDataSelect(data: RecipientData) {
        switch type {
        case .asset:
            onRecipientDataAction?(data)
        case .nft(let asset):
            let data = TransferData(type: .transferNft(asset), recipientData: data, value: .zero, canChangeValue: false)
            onTransferDataSelect(data: data)
        }
    }
    
    func onTransferDataSelect(data: TransferData) {
        onTransferAction?(data)
    }
    
    func onContactAddressSelected(_ address: ContactAddress) {
        self.address = address.address
        self.memo = address.memo.or("")
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
