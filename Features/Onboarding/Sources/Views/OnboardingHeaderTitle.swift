// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct OnboardingHeaderTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(Colors.secondaryText)
            .font(.system(size: 16, weight: .medium))
            .multilineTextAlignment(.center)
            .lineSpacing(Spacing.tiny)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, Spacing.small)
    }
}
