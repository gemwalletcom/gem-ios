// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ContactId: Codable, Sendable, Hashable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public struct Contact: Codable, Sendable, Identifiable, Hashable {
    public let id: ContactId
    public let name: String
    public let description: String?
    
    public init(
        id: ContactId,
        name: String,
        description: String?
    ) {
        self.id = id
        self.name = name
        self.description = description
    }
}
