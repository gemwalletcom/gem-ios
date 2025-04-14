// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Localization
import PrimitivesComponents
import ManageWalletService
import Components
import Style
import SwiftUICore

typealias RecipientDataAction = ((RecipientData) -> Void)?

enum RecipientAddressType: CaseIterable {
    case pinned
    case wallets
    case view
}

enum RecipientScanResult {
    case recipient(address: String, memo: String?, amount: String?)
    case transferData(TransferData)
}

class RecipientViewModel: ObservableObject {
    let wallet: Wallet
    let asset: Asset
    let type: RecipientAssetType
    
    private let manageWalletService: ManageWalletService
    private let onRecipientDataAction: RecipientDataAction
    private let onTransferAction: TransferDataAction
    private let formatter = ValueFormatter(style: .full)
    
    init(
        wallet: Wallet,
        asset: Asset,
        manageWalletService: ManageWalletService,
        type: RecipientAssetType,
        onRecipientDataAction: RecipientDataAction,
        onTransferAction: TransferDataAction
    ) {
        self.wallet = wallet
        self.asset = asset
        self.manageWalletService = manageWalletService
        self.type = type
        self.onRecipientDataAction = onRecipientDataAction
        self.onTransferAction = onTransferAction
    }

    var tittle: String { Localized.Transfer.Recipient.title }
    var recipientField: String { Localized.Transfer.Recipient.addressField }
    var memoField: String { Localized.Transfer.memo }

    var showMemo: Bool { asset.chain.isMemoSupported }
    var chain: Chain { asset.chain }
    
    var recipientSections: [ListItemValueSection<RecipientAddress>] {
        RecipientAddressType.allCases
            .map {
                ListItemValueSection(
                    section: sectionTitle(for: $0),
                    image: sectionImage(for: $0),
                    values: sectionRecipients(for: $0)
                )
            }
            .filter({ !$0.values.isEmpty })
    }

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
    
    func getRecipientData(recipient: RecipientAddress) throws -> RecipientData {
        let recipient = Recipient(name: recipient.name, address: recipient.address, memo: .none) //TODO: Add Memo
        try validateAddress(address: recipient.address)
        return RecipientData(
            recipient: recipient,
            amount: .none
        )
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
    
    // MARK: - Private methods
    
    private func validateAddress(address: String) throws {
        guard asset.chain.isValidAddress(address) else {
            throw TransferError.invalidAddress(asset: asset)
        }
    }
    
    private func sectionRecipients(for section: RecipientAddressType) -> [ListItemValue<RecipientAddress>] {
        manageWalletService.wallets
            .filter { $0.id != wallet.id }
            .filter {
                switch section {
                case .view:
                    $0.type == .view && !$0.isPinned && $0.accounts.first?.chain == asset.chain
                case .wallets:
                    ($0.type == .multicoin || $0.type == .single) && !$0.isPinned && $0.accounts.contains { $0.chain == asset.chain }
                case .pinned:
                    $0.isPinned && $0.accounts.contains { $0.chain == asset.chain }
                }
            }
            .compactMap {
                guard let account = $0.accounts.first(where: { $0.chain == asset.chain }) else { return nil }
                return ListItemValue(value: RecipientAddress(name: $0.name, address: account.address))
            }
    }
    
    private func sectionTitle(for type: RecipientAddressType) -> String {
        switch type {
        case .pinned: Localized.Common.pinned
        case .wallets: Localized.Transfer.Recipient.myWallets
        case .view: Localized.Transfer.Recipient.viewWallets
        }
    }
    
    private func sectionImage(for type: RecipientAddressType) -> Image? {
        switch type {
        case .pinned: Images.System.pin
        case .wallets, .view: nil
        }
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
}

extension RecipientViewModel: Hashable {
    static func == (lhs: RecipientViewModel, rhs: RecipientViewModel) -> Bool {
        return lhs.wallet.id == rhs.wallet.id && lhs.asset == rhs.asset
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wallet.id)
    }
}
