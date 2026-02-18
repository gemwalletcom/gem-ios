// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import ContactService
import PrimitivesComponents
import Store
import Localization

@Observable
@MainActor
public final class ContactsViewModel {
    let service: ContactService

    public var request: ContactsRequest
    public var contacts: [ContactData] = []

    var isPresentingManageContact: ContactData?
    var isPresentingAddContact = false

    public init(service: ContactService) {
        self.service = service
        self.request = ContactsRequest()
    }

    var title: String { Localized.Contacts.title }

    var emptyContent: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .contacts)
    }

    func onAddContactComplete() {
        isPresentingAddContact = false
    }

    func onManageContactComplete() {
        isPresentingManageContact = nil
    }

    func deleteContacts(at offsets: IndexSet) {
        for index in offsets {
            try? service.deleteContact(id: contacts[index].contact.id)
        }
    }
}
