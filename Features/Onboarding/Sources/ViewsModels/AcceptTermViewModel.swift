// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class AcceptTermViewModel: Identifiable {
    var id: String { message }
    let message: String
    var isConfirmed: Bool = false
    
    init(message: String) {
        self.message = message
    }
}
