// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style

final class TermItemViewModel: Identifiable {
    var id: String { message }
    let message: String
    var style: TextStyle {
        isConfirmed ? .body : TextStyle(font: .body, color: Colors.black.opacity(0.8))
    }
    var isConfirmed: Bool = false
    
    init(message: String) {
        self.message = message
    }
}
