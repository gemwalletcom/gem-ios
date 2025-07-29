// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct WidgetEmptyView: View {
    let message: String
    
    init(message: String = "No price data available") {
        self.message = message
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.caption)
                .foregroundColor(Colors.gray)
            Spacer()
        }
    }
}