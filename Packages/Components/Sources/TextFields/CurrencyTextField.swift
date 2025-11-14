// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct CurrencyTextField: View {
    @Environment(\.isEnabled) var isEnabled

    public enum CurrencyPosition {
        case leading
        case trailing
    }

    private enum Constants {
        static let fontSize: CGFloat = 44
        static let fontWeight: Font.Weight = .semibold
        static let minWidth: CGFloat = 40
        static let maxWidth: CGFloat = 210
        static var height: CGFloat {
            UIFont.systemFont(ofSize: fontSize, weight: .semibold).lineHeight
        }
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
                .font(.system(size: Constants.fontSize, weight: Constants.fontWeight))
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .lineLimit(1)
                .padding(currencyPosition == .leading ? .leading : .trailing, .tiny)
                .frame(minWidth: Constants.minWidth, maxWidth: Constants.maxWidth)
                .fixedSize(horizontal: true, vertical: false)
                .disabled(!isEnabled)

            if currencyPosition == .trailing {
                currencySymbolView
            }
        }
        .frame(height: Constants.height) // TODO: Remove after fix bug: https://developer.apple.com/forums/thread/806828
    }

    private var currencySymbolView: some View {
        Text(currencySymbol)
            .font(.system(size: Constants.fontSize, weight: Constants.fontWeight))
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
