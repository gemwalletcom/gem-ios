// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import ContactService
import PrimitivesComponents
import Components
import Store
import Localization

@Observable
@MainActor
public final class ContactsViewModel {

    public enum Mode {
        case view
        case addAddress(AddAddressInput, onComplete: () -> Void)
    }

    let service: ContactService
    let mode: Mode

    public let query: ObservableQuery<ContactsRequest>
    var contacts: [ContactData] { query.value }

    var isPresentingContact: ManageContactViewModel.Mode?

    public init(service: ContactService, mode: Mode) {
        self.service = service
        self.mode = mode
        self.query = ObservableQuery(ContactsRequest(), initialValue: [])
    }

    var title: String { Localized.Contacts.title }

    var emptyContent: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .contacts)
    }

    func listItemModel(for contact: ContactData) -> ListItemModel {
        ListItemModel(
            title: contact.contact.name,
            titleExtra: contact.contact.description,
            imageStyle: .asset(assetImage: AssetImage(type: String(contact.contact.name.prefix(2))))
        )
    }

    func onSelectAddContact() {
        switch mode {
        case .view:
            isPresentingContact = .add
        case .addAddress(let input, _):
            isPresentingContact = .create(input)
        }
    }

    func onSelectContact(_ contact: ContactData) {
        switch mode {
        case .view:
            isPresentingContact = .edit(contact)
        case .addAddress(let input, _):
            let newAddress = ContactAddress.new(
                contactId: contact.contact.id,
                chain: input.chain,
                address: input.address,
                memo: input.memo
            )
            isPresentingContact = .append(ContactData(contact: contact.contact, addresses: contact.addresses + [newAddress]))
        }
    }

    func onManageContactComplete() {
        switch mode {
        case .view:
            isPresentingContact = nil
        case .addAddress(_, let onComplete):
            onComplete()
        }
    }

    func deleteContacts(at offsets: IndexSet) {
        do {
            for index in offsets {
                try service.deleteContact(id: contacts[index].contact.id)
            }
        } catch {
            debugLog("ContactsViewModel deleteContacts error: \(error)")
        }
    }
}
