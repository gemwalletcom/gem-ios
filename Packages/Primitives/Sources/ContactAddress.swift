// Copyright (c). Gem Wallet. All rights reserved.

public struct ContactAddress: Codable, Sendable, Hashable, Identifiable {
    public let id: String?
    public let contact: Contact
    public let address: String
    public let chain: Chain
    public let memo: String?
    
    public init(
        id: String?,
        contact: Contact,
        address: String,
        chain: Chain,
        memo: String?
    ) {
        self.id = id
        self.contact = contact
        self.address = address
        self.chain = chain
        self.memo = memo
    }
}
