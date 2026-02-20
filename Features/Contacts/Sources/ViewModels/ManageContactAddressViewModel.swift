// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import UIKit
import Primitives
import PrimitivesComponents
import Validators
import GemstonePrimitives
import Components
import Style
import Localization
import WalletCorePrimitives

@Observable
@MainActor
public final class ManageContactAddressViewModel {
    public enum Mode {
        case add
        case edit(ContactAddress)
    }

    private let mode: Mode
    private let contactId: String
    private let onComplete: (ContactAddress) -> Void

    var chain: Chain
    var memo: String = ""
    var addressInputModel: InputValidationViewModel
    var isPresentingScanner = false

    public init(
        contactId: String,
        mode: Mode,
        onComplete: @escaping (ContactAddress) -> Void
    ) {
        self.contactId = contactId
        self.mode = mode
        self.onComplete = onComplete

        self.addressInputModel = InputValidationViewModel(mode: .manual, validators: [])

        switch mode {
        case .add:
            self.chain = .bitcoin
        case .edit(let address):
            self.chain = address.chain
            self.memo = address.memo ?? ""
            self.addressInputModel.text = address.address
        }

        updateAddressValidators(for: chain)
    }

    var title: String { Localized.Common.address }
    var buttonTitle: String { Localized.Transfer.confirm }
    var networkTitle: String { Localized.Transfer.network }
    var addressTitle: String { Localized.Common.address }
    var memoTitle: String { Localized.Transfer.memo }
    var showMemo: Bool { chain.isMemoSupported }
    var pasteImage: Image { Images.System.paste }
    var qrImage: Image { Images.System.qrCodeViewfinder }
    var shouldShowInputActions: Bool { addressInputModel.text.isEmpty }

    var networkSelectorModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            state: .data(.plain(Chain.allCases)),
            selectedItems: [chain],
            selectionType: .checkmark
        )
    }

    var buttonState: ButtonState {
        guard addressInputModel.isValid,
              addressInputModel.text.isNotEmpty else {
            return .disabled
        }

        return .normal
    }

    private var currentAddress: ContactAddress {
        ContactAddress.new(
            contactId: contactId,
            chain: chain,
            address: chain.checksumAddress(addressInputModel.text.trimmingCharacters(in: .whitespacesAndNewlines)),
            memo: memo.isEmpty ? nil : memo
        )
    }
}

// MARK: - Actions

extension ManageContactAddressViewModel {
    func onSelectChain(_ chain: Chain) {
        self.chain = chain
        self.memo = ""
        updateAddressValidators(for: chain)
    }

    func onSelectPaste() {
        guard let address = UIPasteboard.general.string else { return }
        addressInputModel.update(text: address)
    }

    func onSelectScan() {
        isPresentingScanner = true
    }

    func onHandleScan(_ result: String) {
        addressInputModel.update(text: result)
    }

    func complete() {
        onComplete(currentAddress)
    }
}

// MARK: - Private

extension ManageContactAddressViewModel {
    private func updateAddressValidators(for chain: Chain) {
        let currentText = addressInputModel.text
        let asset = Asset(chain)
        
        addressInputModel = InputValidationViewModel(
            mode: .manual,
            validators: [
                .required(requireName: Localized.Common.address),
                .address(asset)
            ]
        )
        addressInputModel.text = currentText

        if currentText.isNotEmpty {
            addressInputModel.update()
        }
    }
}
