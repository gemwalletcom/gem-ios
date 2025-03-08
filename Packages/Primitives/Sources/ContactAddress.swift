// Copyright (c). Gem Wallet. All rights reserved.

public struct ContactAddressId: Codable, Sendable, Hashable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public struct ContactAddress: Codable, Sendable, Hashable, Identifiable {
    public var id: ContactAddressId
    public let contactId: ContactId
    public let value: String
    public let chain: Chain
    public let memo: String?
    
    public init(
        id: ContactAddressId,
        contactId: ContactId,
        value: String,
        chain: Chain,
        memo: String?
    ) {
        self.id = id
        self.contactId = contactId
        self.value = value
        self.chain = chain
        self.memo = memo
    }
}
