// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public enum ContactViewType: Identifiable {
    public var id: String { title }
    
    case add
    case view(contact: Contact)
    
    var title: String {
        switch self {
        case .add:
            return "Add Contact"
        case .view(let contact):
            return contact.name
        }
    }
}
