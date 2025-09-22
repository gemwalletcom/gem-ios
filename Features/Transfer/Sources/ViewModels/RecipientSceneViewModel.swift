// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Localization
import PrimitivesComponents
import WalletService
import Components
import Style
import NameService
import Keystore
import WalletsService
import NodeService
import SwiftUI
import ScanService
import Formatters

public typealias RecipientDataAction = ((RecipientData) -> Void)?

@Observable
@MainActor
public final class RecipientSceneViewModel {
    let wallet: Wallet
    let asset: Asset
    let type: RecipientAssetType

    let onTransferAction: TransferDataAction

    private let walletService: WalletService
    private let nameService: any NameServiceable
    private let onRecipientDataAction: RecipientDataAction
    private let formatter = ValueFormatter(style: .full)

    var isPresentingScanner: RecipientScene.Field?
    var nameResolveState: NameRecordState = .none
    var memo: String = ""
    var amount: String = ""
    var addressInputModel: InputValidationViewModel

    public init(
        wallet: Wallet,
        asset: Asset,
        walletService: WalletService,
        nameService: any NameServiceable,
        type: RecipientAssetType,
        onRecipientDataAction: RecipientDataAction,
        onTransferAction: TransferDataAction
    ) {
        self.wallet = wallet
        self.asset = asset
        self.walletService = walletService
        self.nameService = nameService
        self.type = type
        self.onRecipientDataAction = onRecipientDataAction
        self.onTransferAction = onTransferAction

        self.addressInputModel = InputValidationViewModel(
            mode: .manual,
            validators: [
                .required(requireName: Localized.Transfer.Recipient.addressField),
                .address(asset)
            ]
        )
    }

    var tittle: String { Localized.Transfer.Recipient.title }
    var recipientField: String { Localized.Transfer.Recipient.addressField }
    var memoField: String { Localized.Transfer.memo }

    var actionButtonTitle: String { Localized.Common.continue }
    var actionButtonState: ButtonState {
        switch nameResolveState {
        case .none: addressInputModel.isValid && addressInputModel.text.isNotEmpty ? .normal : .disabled
        case .loading, .error: .disabled
        case .complete: .normal
        }
    }

    var showMemo: Bool { asset.chain.isMemoSupported }
    var chain: Chain { asset.chain }
    
    var nameRecordViewModel: NameRecordViewModel {
        NameRecordViewModel(chain: chain, nameService: nameService)
    }

    var pasteImage: Image { Images.System.paste }
    var qrImage: Image { Images.System.qrCode }
    var shouldShowInputActions: Bool { addressInputModel.text.isEmpty }

    var recipientSections: [ListItemValueSection<RecipientAddress>] {
        RecipientAddressType.allCases
            .map {
                ListItemValueSection(
                    section: sectionTitle(for: $0),
                    image: sectionImage(for: $0),
                    values: sectionRecipients(for: $0)
                )
            }
            .filter({ $0.values.isNotEmpty })
    }
}

// MARK: - Actions

extension RecipientSceneViewModel {
    func onContinue() {
        guard nameResolveState.result != nil || addressInputModel.update() else { return }

        handle(
            recipientData: makeRecipientData(
                name: nameResolveState.result,
                address: addressInputModel.text,
                memo: memo,
                amount: amount.isEmpty ? .none : amount
            )
        )
    }

    func onSelectPaste(field: RecipientScene.Field) {
        guard let string = UIPasteboard.general.string else { return }
        addressInputModel.update(text: string.trim())
    }

    func onSelectScan(field: RecipientScene.Field) {
        isPresentingScanner = field
    }

    func onHandleScan(_ result: String, for field: RecipientScene.Field) {
        switch field {
        case .address:
            do {
                try handleAddressScan(result)
            } catch {
                addressInputModel.update(error: error)
            }

        case .memo:
            memo = result
        }
    }

    func onChangeNameResolverState(_: NameRecordState, newState: NameRecordState) {
        // Remove address if any error, on success resolve
        if newState.result != nil {
            addressInputModel.update(error: nil)
        }
    }

    func onChangeAddressText(_: String, new: String) {
        // Clear previously auto-filled amount if user edits the address
        if !amount.isEmpty {
            amount = .empty
        }
    }

    func onSelectRecipient(_ recipient: RecipientAddress) {
        handle(
            recipientData: makeRecipientData(recipient: recipient)
        )
    }
}

// MARK: - Private

extension RecipientSceneViewModel {
    private func makeRecipientData(name: NameRecord?, address: String, memo: String?, amount: String?) -> RecipientData {
        let recipient: Recipient = {
            if let result = name {
                return Recipient(name: result.name, address: result.address, memo: memo)
            }
            return Recipient(name: .none, address: address, memo: memo)
        }()

        return RecipientData(
            recipient: recipient,
            amount: amount
        )
    }

    private func makeRecipientData(recipient: RecipientAddress) -> RecipientData {
        RecipientData(
            recipient: Recipient(
                name: recipient.name,
                address: recipient.address,
                memo: nil // TODO: - add memo later
            ),
            amount: .none
        )
    }

    //TODO: Add unit tests, will be added once moved to package
    private func paymentScan(string: String) throws -> PaymentScanResult {
        let payment = try PaymentURLDecoder.decode(string)

        return PaymentScanResult(
            address: payment.address,
            amount: payment.amount,
            memo: payment.memo
        )
    }

     func getRecipientScanResult(payment: PaymentScanResult) throws -> RecipientScanResult {
        if let amount = payment.amount, (showMemo ? ((payment.memo?.isEmpty) == nil) : true),
           asset.chain.isValidAddress(payment.address)
        {
            let transferType: TransferDataType = switch type {
            case .asset(let asset): .transfer(asset)
            case .nft(let asset): .transferNft(asset)
            }

            let value = try formatter.inputNumber(from: amount, decimals: asset.decimals.asInt)
            let recipientData = RecipientData(
                recipient: Recipient(
                    name: .none,
                    address: payment.address,
                    memo: payment.memo
                ),
                amount: .none
            )
            return .transferData(
                TransferData(type: transferType, recipientData: recipientData, value: value, canChangeValue: false)
            )
        }

        return .recipient(address: payment.address, memo: payment.memo, amount: payment.amount)
    }

    private func sectionRecipients(for section: RecipientAddressType) -> [ListItemValue<RecipientAddress>] {
        walletService.wallets
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

    private func sectionImage(for type: RecipientAddressType) -> Image {
        switch type {
        case .pinned: Images.System.pin
        case .wallets: Images.System.wallet
        case .view: Images.System.eye
        }
    }

    private func handleAddressScan(_ string: String) throws {
        let payment = try paymentScan(string: string)
        let scanResult = try getRecipientScanResult(payment: payment)
        switch scanResult {
        case .transferData(let data):
            handle(transferData: data)
        case .recipient(let address, let memo, let amount):
            // TODO: - open if all fields filled
            addressInputModel.update(text: address)

            if let memo = memo { self.memo = memo }
            if let amount = amount { self.amount = amount }
        }
    }

    private func handle(recipientData: RecipientData) {
        switch type {
        case .asset:
            onRecipientDataAction?(recipientData)
        case .nft(let asset):
            handle(transferData: TransferData(type: .transferNft(asset), recipientData: recipientData, value: .zero, canChangeValue: true))
        }
    }

    private func handle(transferData: TransferData) {
        onTransferAction?(transferData)
    }
}
