// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style

final class TermItemViewModel: Identifiable {
    let message: String
    var style: TextStyle {
        isConfirmed ? .body : TextStyle(font: .body, color: Colors.black.opacity(.strong))
    }
    var isConfirmed: Bool = false
    
    init(message: String) {
        self.message = message
    }
    
    var id: String { message }
}
