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
import Formatters

@Observable
@MainActor
public final class ManageContactViewModel {

    public enum Mode {
        case add
        case edit(ContactData)
    }

    private let service: ContactService
    private let mode: Mode
    private let onComplete: (() -> Void)?

    let contactId: String

    var nameInputModel: InputValidationViewModel
    var description: String = ""
    var addresses: [ContactAddress] = []
    var isPresentingAddAddress = false
    var isPresentingManageAddress: ContactAddress?

    public init(
        service: ContactService,
        mode: Mode,
        onComplete: (() -> Void)? = nil
    ) {
        self.service = service
        self.mode = mode
        self.onComplete = onComplete

        self.nameInputModel = InputValidationViewModel(
            mode: .onDemand,
            validators: [.required(requireName: Localized.Wallet.name)]
        )

        switch mode {
        case .add:
            self.contactId = UUID().uuidString
        case .edit(let contactData):
            self.contactId = contactData.contact.id
            self.nameInputModel.text = contactData.contact.name
            self.description = contactData.contact.description ?? ""
            self.addresses = contactData.addresses
        }
    }

    var title: String { Localized.Contacts.contact }

    var isAddMode: Bool {
        switch mode {
        case .add: true
        case .edit: false
        }
    }
    var buttonTitle: String { Localized.Common.save }
    var nameTitle: String { Localized.Wallet.name }
    var descriptionTitle: String { Localized.Common.description }
    var contactSectionTitle: String { Localized.Contacts.contact }
    var addressesSectionTitle: String { Localized.Contacts.addresses }

    var buttonState: ButtonState {
        guard nameInputModel.isValid,
              nameInputModel.text.isNotEmpty,
              addresses.isNotEmpty else {
            return .disabled
        }

        switch mode {
        case .add:
            return .normal
        case .edit:
            return hasChanges ? .normal : .disabled
        }
    }

    private var hasChanges: Bool {
        switch mode {
        case .add:
            return true
        case .edit(let contactData):
            let trimmedName = nameInputModel.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDescription = description.isEmpty ? nil : description
            return contactData.contact.name != trimmedName
                || contactData.contact.description != trimmedDescription
                || contactData.addresses != addresses
        }
    }

    private var currentContact: Contact {
        let createdAt: Date = switch mode {
        case .add: .now
        case .edit(let contactData): contactData.contact.createdAt
        }
        return Contact(
            id: contactId,
            name: nameInputModel.text.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description,
            createdAt: createdAt,
            updatedAt: .now
        )
    }
    
    func listItemModel(for address: ContactAddress) -> ListItemModel {
        ListItemModel(
            title: address.chain.asset.name,
            titleExtra: AddressFormatter(style: .short, address: address.address, chain: address.chain).value(),
            imageStyle: .asset(assetImage: AssetIdViewModel(assetId: address.chain.assetId).assetImage)
        )
    }

    func onAddAddressComplete(_ address: ContactAddress) {
        addresses.append(address)
        isPresentingAddAddress = false
    }

    func onManageAddressComplete(_ address: ContactAddress) {
        if let index = addresses.firstIndex(where: { $0.id == address.id }) {
            addresses[index] = address
        }
        isPresentingManageAddress = nil
    }

    func deleteAddress(at offsets: IndexSet) {
        addresses.remove(atOffsets: offsets)
    }

    func onSave() {
        do {
            switch mode {
            case .add: try service.addContact(currentContact, addresses: addresses)
            case .edit: try service.updateContact(currentContact, addresses: addresses)
            }
            onComplete?()
        } catch {
            debugLog("ManageContactViewModel save error: \(error)")
        }
    }
}
