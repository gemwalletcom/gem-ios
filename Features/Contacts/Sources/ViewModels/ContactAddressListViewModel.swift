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
public class ContactAddressListViewModel: Sendable {
    
    let contactService: ContactService
    var addressListRequest: ContactAddressListRequest
    public let contact: Contact
    public let chain: Chain?

    var title: String { contact.name }

    public init(
        chain: Chain?,
        contact: Contact,
        contactService: ContactService
    ) {
        self.chain = chain
        self.contact = contact
        self.contactService = contactService
        
        self.addressListRequest = ContactAddressListRequest(
            contactId: contact.id,
            chain: chain,
            searchQuery: nil
        )
    }
    
    func input(from address: ContactAddress?) -> AddContactAddressInput {
        guard let address else {
            return AddContactAddressInput()
        }
        
        return AddContactAddressInput(
            id: address.id,
            address: address.value,
            chain: address.chain,
            memo: (address.memo).valueOrEmpty
        )
    }
    
    func delete(address: ContactAddress) throws {
        _ = try contactService.delete(address: address)
    }
    
    func buildListItemViews(addresses: [ContactAddress]) -> [ContactAddressListViewItem<ContactAddress>] {
        addresses
            .map {
                let memo: TextValue? = $0.memo.flatMap {
                    guard !$0.isEmpty else {
                        return nil
                    }
                    
                    return .init(text: "Memo: \($0)", style: .bodySecondary)
                }
                
                return ContactAddressListViewItem<ContactAddress>(
                    id: $0.id.id,
                    address: .init(text: $0.value, style: .body),
                    memo: memo,
                    chain: .init(text: $0.chain.rawValue.capitalized, style: .caption),
                    image: ChainImage(chain: $0.chain),
                    object: $0
                )
        }
    }
}
