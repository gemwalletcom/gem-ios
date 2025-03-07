// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public protocol CurrencyInputConfigurable {
    var placeholder: String { get }
    var currencySymbol: String { get }
    var currencyPosition: CurrencyTextField.CurrencyPosition { get }
    var secondaryText: String { get }
    var keyboardType: UIKeyboardType { get }
    var sanitizer: ((String) -> String)? { get }
}

public struct CurrencyInputView: View {
    @Binding var text: String

    private let placeholder: String
    private let currencySymbol: String
    private let currencyPosition: CurrencyTextField.CurrencyPosition
    private let secondaryText: String
    private let keyboardType: UIKeyboardType

    private let sanitizer: ((String) -> String)?

    public init(
        placeholder: String = "0",
        text: Binding<String>,
        currencySymbol: String,
        currencyPosition: CurrencyTextField.CurrencyPosition,
        secondaryText: String,
        keyboardType: UIKeyboardType,
        sanitizer: ((String) -> String)? = nil
    ) {
        _text = text
        self.secondaryText = secondaryText
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.currencySymbol = currencySymbol
        self.currencyPosition = currencyPosition
        self.sanitizer = sanitizer
    }

    public init(text: Binding<String>, config: CurrencyInputConfigurable) {
        self.init(
            placeholder: config.placeholder,
            text: text,
            currencySymbol: config.currencySymbol,
            currencyPosition: config.currencyPosition,
            secondaryText: config.secondaryText,
            keyboardType: config.keyboardType,
            sanitizer: config.sanitizer
        )
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            CurrencyTextField(
                placeholder,
                text: $text,
                currencySymbol: currencySymbol,
                currencyPosition: currencyPosition,
                keyboardType: keyboardType
            )
            .ifLet(sanitizer) { view, sanitize in
                view.onChange(of: text) { _, newValue in
                    text = sanitize(newValue)
                }
            }

            Text(secondaryText)
                .textStyle(.calloutSecondary.weight(.medium))
                .frame(minHeight: .list.image)
        }
    }
}
