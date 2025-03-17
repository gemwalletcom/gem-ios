// Copyright (c). Gem Wallet. All rights reserved.

public struct ContactAddressData: Codable, Sendable, Hashable, Identifiable {
    public var id: String {
        [contact.id.id, address.id].compactMap { $0 }.joined(separator: "_")
    }
    
    public let address: ContactAddress
    public let contact: Contact
    
    public init(address: ContactAddress, contact: Contact) {
        self.address = address
        self.contact = contact
    }
}
