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

    var title = "Contacts"

    public init(
        contactService: ContactService
    ) {
        self.contactService = contactService
        
        self.contactRequest = ContactListRequest(
            searchQuery: nil
        )
    }
    
    func input(from contact: Contact?) -> AddContactInput {
        guard let contact else {
            return AddContactInput()
        }
        
        return AddContactInput(
            id: contact.id,
            name: contact.name,
            description: contact.description.valueOrEmpty
        )
    }
    
    func delete(contact: Contact) throws {
        _ = try contactService.delete(contact: contact)
    }
    
    func buildListItemViews(contacts: [Contact]) -> [ContactAddressListViewItem<Contact>] {
        contacts
            .map {
                return ContactAddressListViewItem<Contact>(
                    id: $0.id.id,
                    name: TextValue(text: $0.name, style: .bodyBold),
                    description: $0.description.flatMap { TextValue(text: $0, style: .caption) },
                    object: $0
                )
        }
    }
}
