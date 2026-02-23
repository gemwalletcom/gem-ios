// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension ManageContactViewModel {
    public enum Mode: Identifiable {
        case add
        case create(AddAddressInput)
        case append(ContactData)
        case edit(ContactData)

        public var id: String {
            switch self {
            case .add: "add"
            case .create(let input): "create-\(input.chain.rawValue)-\(input.address)"
            case .append(let contactData): "append-\(contactData.contact.id)"
            case .edit(let contactData): "edit-\(contactData.contact.id)"
            }
        }

        var contact: Contact? {
            switch self {
            case .add, .create: nil
            case .append(let contactData), .edit(let contactData): contactData.contact
            }
        }
    }
}
