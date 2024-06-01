// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct RecipientAddress {
    let name: String
    let address: String
}
extension RecipientAddress: Identifiable {
    var id: String {
        return String("\(name)\(address)")
    }
}
extension RecipientAddress: Hashable {}
