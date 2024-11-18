// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct PrivacyToggleView: View {
    @Binding private var isEnabled: Bool
    private let text: String
    private let placeholder: String

    public init(
        _ text: String,
        isEnabled: Binding<Bool>,
        placeholder: String = "*****"
    ) {
        _isEnabled = isEnabled
        self.text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        if isEnabled {
            Button(action: onTogglePrivacy) {
                Text(placeholder)
                    .offset(y: Spacing.small)
                    .foregroundStyle(Colors.whiteSolid)
            }
            .padding(.horizontal)
            .background(
                Capsule(style: .circular)
                    .foregroundStyle(Colors.blue)
            )
        } else {
            Button(action: onTogglePrivacy) {
                Text(text)
            }
        }
    }
}

// MARK: - Actions

extension PrivacyToggleView {
    private func onTogglePrivacy() {
        isEnabled.toggle()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isEnabled: Bool = false
    return PrivacyToggleView(
        "$12323123.23",
        isEnabled: $isEnabled,
        placeholder: "*****"
    )
}
