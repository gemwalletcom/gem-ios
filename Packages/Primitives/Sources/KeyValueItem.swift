// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct KeyValueItem: Identifiable, Sendable {
    public var id: String { [title, value].joined() }
    public let title: String
    public let value: String
    
    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}
