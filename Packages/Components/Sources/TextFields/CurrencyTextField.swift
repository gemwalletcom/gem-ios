// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct CurrencyTextField: View {
    public enum SymbolPosition {
        case leading
        case trailing
    }

    @Binding var text: String

    private let currencySymbol: String
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let symbolPosition: SymbolPosition
    private let isInputDisabled: Bool

    public init(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType,
        currencySymbol: String,
        symbolPosition: SymbolPosition,
        isInputDisabled: Bool = false
    ) {
        _text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.currencySymbol = currencySymbol
        self.symbolPosition = symbolPosition
        self.isInputDisabled = isInputDisabled
    }

    public var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            if symbolPosition == .leading {
                currencySymbolView
            }

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundStyle(Colors.black)
                .font(.system(size: 52).weight(.semibold))
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .lineLimit(1)
                .padding(symbolPosition == .leading ? .leading : .trailing, Spacing.small)
                .frame(minWidth: 40, maxWidth: 260)
                .fixedSize(horizontal: true, vertical: false)
                .disabled(isInputDisabled)

            if symbolPosition == .trailing {
                currencySymbolView
            }
        }
    }

    private var currencySymbolView: some View {
        Text(currencySymbol)
            .font(.system(size: 52).weight(.semibold))
            .foregroundStyle(Colors.black)
            .lineLimit(1)
            .fixedSize()
    }
}

#Preview {
    @State var textLeading: String = "10"
    @State var textTrailing: String = "100"

    return VStack {
        CurrencyTextField("0", text: $textLeading, keyboardType: .numberPad, currencySymbol: "$", symbolPosition: .leading)
        CurrencyTextField("0", text: $textTrailing, keyboardType: .numberPad, currencySymbol: "$", symbolPosition: .trailing)
    }
}
