// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public enum ContactAddressViewType: Identifiable {
    public var id: String { title }
    
    case edit(address: ContactAddress)
    case add(contact: Contact, chain: Chain)
    
    var title: String {
        switch self {
        case .add:
            return "Add address"
        case .edit:
            return "Edit address"
        }
    }
    
    var contact: Contact {
        switch self {
        case .edit(let address):
            return address.contact
        case .add(let contact, _):
            return contact
        }
    }
}
