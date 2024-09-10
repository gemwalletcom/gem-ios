// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct BuyAssetInputField: View {
    @Binding private var text: String

    enum FiatField: Int, Hashable, Identifiable {
        case fiat
        var id: String { String(rawValue) }
    }

    private var focusedFieldBinding: FocusState<FiatField?>.Binding
    private let currencySymbol: String

    init(text: Binding<String>, currencySymbol: String, focusedField: FocusState<FiatField?>.Binding) {
        _text = text
        focusedFieldBinding = focusedField
        self.currencySymbol = currencySymbol
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(currencySymbol)
                .font(.system(size: 52).weight(.semibold))
                .foregroundStyle(Colors.black)
                .lineLimit(1)
                .padding(.trailing, Spacing.extraSmall)
                .fixedSize(horizontal: true, vertical: false)

            TextField(String.zero, text: $text)
                .keyboardType(.numberPad)
                .foregroundStyle(Colors.black)
                .font(.system(size: 52))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .lineLimit(1)
                .frame(minWidth: 40, maxWidth: 260)
                .fixedSize()
                .focused(focusedFieldBinding, equals: .fiat)
        }
    }
}

#Preview {
    @State var text: String = "10"
    @FocusState var focusedField: BuyAssetInputField.FiatField?
    return BuyAssetInputField(text: $text, currencySymbol: "$", focusedField: $focusedField)
}
