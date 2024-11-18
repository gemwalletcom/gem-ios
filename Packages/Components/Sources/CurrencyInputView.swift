// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public protocol CurrencyInputConfigurable {
    var placeholder: String { get }
    var currencySymbol: String { get }
    var currencyPosition: CurrencyTextField.CurrencyPosition { get }
    var secondaryText: String { get }
    var keyboardType: UIKeyboardType { get }
}

public struct CurrencyInputView: View {
    @Binding var text: String

    private let placeholder: String
    private let currencySymbol: String
    private let currencyPosition: CurrencyTextField.CurrencyPosition
    private let secondaryText: String
    private let keyboardType: UIKeyboardType

    public init(
        placeholder: String = "0",
        text: Binding<String>,
        currencySymbol: String,
        currencyPosition: CurrencyTextField.CurrencyPosition,
        secondaryText: String,
        keyboardType: UIKeyboardType
    ) {
        _text = text
        self.secondaryText = secondaryText
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.currencySymbol = currencySymbol
        self.currencyPosition = currencyPosition
    }

    public init(text: Binding<String>, config: CurrencyInputConfigurable) {
        self.init(
            text: text,
            currencySymbol: config.currencySymbol,
            currencyPosition: config.currencyPosition,
            secondaryText: config.secondaryText,
            keyboardType: config.keyboardType
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

            Text(secondaryText)
                .textStyle(.calloutSecondary.weight(.medium))
                .frame(minHeight: Sizing.list.image)
        }
    }
}
