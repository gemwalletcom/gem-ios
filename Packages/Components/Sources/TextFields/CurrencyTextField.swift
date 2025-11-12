// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct CurrencyTextField: View {
    @Environment(\.isEnabled) var isEnabled

    public enum CurrencyPosition {
        case leading
        case trailing
    }

    @Binding var text: String

    private let currencySymbol: String
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let currencyPosition: CurrencyPosition

    public init(
        _ placeholder: String,
        text: Binding<String>,
        currencySymbol: String,
        currencyPosition: CurrencyPosition,
        keyboardType: UIKeyboardType
    ) {
        _text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.currencySymbol = currencySymbol
        self.currencyPosition = currencyPosition
    }

    public var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            if currencyPosition == .leading {
                currencySymbolView
            }
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundStyle(Colors.black)
                .font(.system(size: 44).weight(.semibold))
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .lineLimit(1)
                .padding(currencyPosition == .leading ? .leading : .trailing, .tiny)
                .frame(minWidth: 40, maxWidth: 210)
                .fixedSize(horizontal: true, vertical: false)
                .disabled(!isEnabled)

            if currencyPosition == .trailing {
                currencySymbolView
            }
        }
        .frame(height: 54)
    }

    private var currencySymbolView: some View {
        Text(currencySymbol)
            .font(.system(size: 44).weight(.semibold))
            .foregroundStyle(Colors.black)
            .lineLimit(1)
            .fixedSize()
    }
}

#Preview {
    @Previewable @State var textLeading: String = "10"
    @Previewable @State var textTrailing: String = "100"

    return VStack {
        CurrencyTextField("0", text: $textLeading, currencySymbol: "$", currencyPosition: .leading, keyboardType: .numberPad)
        CurrencyTextField("0", text: $textTrailing, currencySymbol: "$", currencyPosition: .trailing, keyboardType: .decimalPad)
    }
}
