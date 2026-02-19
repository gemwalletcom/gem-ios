// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Formatters

struct ContactRecipientSectionViewModel {
    private let contacts: [ContactData]
    private let chain: Chain

    init(contacts: [ContactData], chain: Chain) {
        self.contacts = contacts
        self.chain = chain
    }

    var listItems: [ListItemValue<RecipientAddress>] {
        contacts.flatMap { contactData in
            Dictionary(grouping: contactData.addresses, by: { $0.address.lowercased() })
                .compactMap { $0.value.first }
                .map { address in
                    ListItemValue(
                        title: contactData.contact.name,
                        subtitle: AddressFormatter(address: address.address, chain: address.chain).value(),
                        value: RecipientAddress(name: contactData.contact.name, address: address.address, memo: address.memo)
                    )
                }
        }
    }
}
