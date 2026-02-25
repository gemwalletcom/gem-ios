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

        var contact: Contact? {
            switch self {
            case .add: nil
            case .edit(let contactData): contactData.contact
            }
        }
    }

    private let service: ContactService
    private let mode: Mode
    private let onComplete: (() -> Void)?

    let contactId: String

    var nameInputModel: InputValidationViewModel
    var description: String = ""
    var addresses: [ContactAddress] = []
    var isPresentingAddAddress = false
    var isPresentingContactAddress: ContactAddress?

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

        return .normal
    }

    private var currentContact: Contact {
        Contact.new(
            id: contactId,
            name: nameInputModel.text.trim(),
            description: description.isEmpty ? nil : description,
            createdAt: mode.contact?.createdAt ?? .now
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
        isPresentingContactAddress = nil
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
