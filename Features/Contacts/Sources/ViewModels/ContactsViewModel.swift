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
    let service: ContactService

    public let query: ObservableQuery<ContactsRequest>
    var contacts: [ContactData] { query.value }

    var isPresentingContact: ContactData?
    var isPresentingAddContact = false

    public init(service: ContactService) {
        self.service = service
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

    func onAddContactComplete() {
        isPresentingAddContact = false
    }

    func onManageContactComplete() {
        isPresentingContact = nil
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
