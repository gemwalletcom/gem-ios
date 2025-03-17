// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import SwiftUI
import ContactService
import GRDBQuery
import Store
import Combine
import Components
import PrimitivesComponents

@Observable
@MainActor
public class ContactListViewModel: Sendable {
    let contactService: ContactService
    var contactRequest: ContactListRequest

    public init(contactService: ContactService) {
        self.contactService = contactService
        self.contactRequest = ContactListRequest()
    }
    
    var title = "Contacts"
    
    func delete(contact: Contact) throws {
        _ = try contactService.delete(contact: contact)
    }
    
    func buildListItemViews(contacts: [Contact]) -> [ContactListViewItem<Contact>] {
        contacts
            .map {
                return ContactListViewItem<Contact>(
                    id: $0.id.id,
                    name: $0.name,
                    description: $0.description?.isEmpty == false ? $0.description : nil,
                    object: $0
                )
        }
    }
}
