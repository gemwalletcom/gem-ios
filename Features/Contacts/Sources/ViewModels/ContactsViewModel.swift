// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import ContactService
import Components
import PrimitivesComponents
import Store

@Observable
@MainActor
public final class ContactsViewModel {
    let service: ContactService

    public var request: ContactsRequest
    public var contacts: [Contact] = []

    var isPresentingManageContact: Contact?
    var isPresentingAddContact = false

    public init(service: ContactService) {
        self.service = service
        self.request = ContactsRequest()
    }

    var title: String { "Contacts" }

    var emptyContent: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .contacts)
    }

    // MARK: - Actions

    func onAddContactComplete() {
        isPresentingAddContact = false
    }

    func onManageContactComplete() {
        isPresentingManageContact = nil
    }

    func deleteContacts(at offsets: IndexSet) {
        for index in offsets {
            try? service.deleteContact(id: contacts[index].id)
        }
    }
}
