// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ListSection<T> {
    public let title: String
    public let values: T
    
    public init(title: String, values: T) {
        self.title = title
        self.values = values
    }
}

extension ListSection: Identifiable {
    public var id: String { title }
}
