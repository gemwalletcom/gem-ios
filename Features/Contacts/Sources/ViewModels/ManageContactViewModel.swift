// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import UIKit
import Primitives
import ContactService
import PrimitivesComponents
import Validators
import GemstonePrimitives
import Components
import Style
import Localization

@Observable
@MainActor
public final class ManageContactViewModel {
    private let service: ContactService
    private let contact: Contact?
    private let onComplete: (() -> Void)?

    var chain: Chain?
    var memo: String = ""
    var description: String = ""
    var addressInputModel: InputValidationViewModel
    var nameInputModel: InputValidationViewModel

    public init(
        service: ContactService,
        contact: Contact? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.service = service
        self.contact = contact
        self.onComplete = onComplete

        self.nameInputModel = InputValidationViewModel(mode: .onDemand, validators: [.required(requireName: Localized.Wallet.name)])
        self.addressInputModel = InputValidationViewModel(mode: .manual, validators: [])
        self.chain = contact?.chain ?? Chain.allCases.first

        if let contact {
            self.memo = contact.memo ?? ""
            self.description = contact.description ?? ""
            self.nameInputModel.text = contact.name
            self.addressInputModel.text = contact.address
        }

        if let chain {
            updateAddressValidators(for: chain)
        }
    }

    var isEditing: Bool { contact != nil }
    var title: String { isEditing ? "Edit Contact" : "Add Contact" }
    var saveButtonTitle: String { Localized.Transfer.confirm }
    var networkTitle: String { Localized.Transfer.network }
    var nameTitle: String { Localized.Wallet.name }
    var addressTitle: String { Localized.Common.address }
    var memoTitle: String { Localized.Transfer.memo }
    var descriptionTitle: String { Localized.Common.description }
    var showMemo: Bool { chain?.isMemoSupported ?? false }
    var pasteImage: Image { Images.System.paste }
    var shouldShowInputActions: Bool { addressInputModel.text.isEmpty }
    
    var networkSelectorModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            state: .data(.plain(Chain.allCases)),
            selectedItems: [chain].compactMap { $0 },
            selectionType: .checkmark
        )
    }

    var saveButtonState: ButtonState {
        guard chain != nil,
              nameInputModel.isValid,
              nameInputModel.text.isNotEmpty,
              addressInputModel.isValid,
              addressInputModel.text.isNotEmpty else {
            return .disabled
        }
        return .normal
    }
}

// MARK: - Actions

extension ManageContactViewModel {
    func onSelectChain(_ chain: Chain) {
        self.chain = chain
        self.memo = ""
        updateAddressValidators(for: chain)
    }

    func onSelectPaste() {
        guard let address = UIPasteboard.general.string else { return }
        addressInputModel.update(text: address)
    }

    func onSave() {
        guard let chain else { return }

        nameInputModel.update()
        addressInputModel.update()

        guard nameInputModel.isValid, addressInputModel.isValid else { return }

        let contact = Contact(
            name: nameInputModel.text.trimmingCharacters(in: .whitespacesAndNewlines),
            address: addressInputModel.text.trimmingCharacters(in: .whitespacesAndNewlines),
            chain: chain,
            memo: memo.isEmpty ? nil : memo,
            description: description.isEmpty ? nil : description
        )

        do {
            if isEditing {
                try service.updateContact(contact)
            } else {
                try service.addContact(contact)
            }
            onComplete?()
        } catch {
            debugLog("ManageContactViewModel save error: \(error)")
        }
    }
}

// MARK: - Private

extension ManageContactViewModel {
    private func updateAddressValidators(for chain: Chain) {
        let currentText = addressInputModel.text
        let asset = Asset(
            id: AssetId(chain: chain, tokenId: nil),
            name: .empty,
            symbol: .empty,
            decimals: 0,
            type: .native
        )
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
