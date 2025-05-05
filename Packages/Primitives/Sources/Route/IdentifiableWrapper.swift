// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public class IdentifiableWrapper: Identifiable {
    public let value: any Identifiable

    public init(value: any Identifiable) {
        self.value = value
    }
}
