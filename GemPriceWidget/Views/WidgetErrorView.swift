// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct WidgetErrorView: View {
    let error: String?
    let showMessage: Bool
    
    init(error: String?, showMessage: Bool = true) {
        self.error = error
        self.showMessage = showMessage
    }
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: SystemImage.exclamationmarkTriangle)
                .font(.title2)
                .foregroundColor(Colors.gray)
            if showMessage, let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Colors.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.small)
            }
            Spacer()
        }
    }
}