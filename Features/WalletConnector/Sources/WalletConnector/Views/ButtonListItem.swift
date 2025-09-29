// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

struct ButtonListItem: View {
    let title: String
    let image: Image
    let action: () -> Void

    init(
        title: String,
        image: Image,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.action = action
    }
    
    var body: some View {
        Button(role: .none, action: action) {
            HStack {
                image
                Text(title)
            }
        }
    }
}
