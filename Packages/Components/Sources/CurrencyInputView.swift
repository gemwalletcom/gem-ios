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
    var action: CurrencyInputActionStyle? { get }
    var onTapActionButton: (() -> Void)? { get }
}

public struct CurrencyInputView: View {
    @Binding var text: String

    private let placeholder: String
    private let currencySymbol: String
    private let currencyPosition: CurrencyTextField.CurrencyPosition
    private let secondaryText: String
    private let keyboardType: UIKeyboardType
    private let action: CurrencyInputActionStyle?
    private let onTapActionButton: (() -> Void)?
    private let sanitizer: ((String) -> String)?

    public init(
        placeholder: String = "0",
        text: Binding<String>,
        currencySymbol: String,
        currencyPosition: CurrencyTextField.CurrencyPosition,
        secondaryText: String,
        keyboardType: UIKeyboardType,
        action: CurrencyInputActionStyle? = nil,
        onTapActionButton: (() -> Void)? = nil,
        sanitizer: ((String) -> String)? = nil
    ) {
        _text = text
        self.secondaryText = secondaryText
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.currencySymbol = currencySymbol
        self.currencyPosition = currencyPosition
        self.action = action
        self.onTapActionButton = onTapActionButton
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
            action: config.action,
            onTapActionButton: config.onTapActionButton,
            sanitizer: config.sanitizer
        )
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: .small) {
                if let action, action.position == .amount {
                    actionButton(action: action)
                }

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
            }

            if let action, action.position == .secondary {
                actionButton(action: action)
            } else {
                secondaryTextView
            }
        }
    }
    
    @ViewBuilder
    func actionButton(action: CurrencyInputActionStyle) -> some View {
        Button {
            onTapActionButton?()
        } label: {
            switch action.position {
            case .amount:
                actionImage
            case .secondary:
                HStack {
                    secondaryTextView
                    actionImage
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(self.action == nil)
    }
    
    @ViewBuilder
    var actionImage: some View {
        if let image = action?.image {
            image
                .resizable()
                .frame(width: Sizing.image.small, height: Sizing.image.small)
                .foregroundColor(Colors.gray)
        }
    }

    var secondaryTextView: some View {
        Text(secondaryText)
            .textStyle(.calloutSecondary.weight(.medium))
            .frame(minHeight: .list.image)
    }
}
