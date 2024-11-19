// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct PrivacyText: View {
    @Binding private var isEnabled: Bool

    private let text: String
    private let placeholder: String

    public init(
        _ text: String,
        isEnabled: Binding<Bool>,
        placeholder: String = "*****"
    ) {
        self.text = text
        self.placeholder = placeholder
        _isEnabled = isEnabled
    }

    public var body: some View {
        Text(displayText)
    }

    private var displayText: String {
        isEnabled ? placeholder : text
    }
}
