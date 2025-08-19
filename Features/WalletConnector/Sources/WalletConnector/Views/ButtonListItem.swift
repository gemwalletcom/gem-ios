// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

struct ButtonListItem: View {
    let title: String
    let image: Image
    let action: () -> Void
    
    var body: some View {
        Button(role: .none, action: action) {
            HStack {
                image
                Text(title)
            }
        }
    }
}
