// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct BuyAssetInputField: View {
    @Binding private var value: Double

    enum FiatField: Int, Hashable, Identifiable {
        case fiat
        var id: String { String(rawValue) }
    }

    private var focusedFieldBinding: FocusState<FiatField?>.Binding

    private var textBinding: Binding<String> {
        Binding<String>(
            get: {
                value == 0 ? "" : String(format: "%.0f", value)
            },
            set: {
                if let newValue = Double($0), !newValue.isNaN {
                    value = newValue
                } else if $0.isEmpty {
                    value = 0
                }
            }
        )
    }

    private let currencySymbol: String

    init(value: Binding<Double>, currencySymbol: String, focusedField: FocusState<FiatField?>.Binding) {
        _value = value
        focusedFieldBinding = focusedField
        self.currencySymbol = currencySymbol
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(currencySymbol)
                .font(.system(size: 52).weight(.semibold))
                .foregroundStyle(Colors.black)
                .lineLimit(1)
                .padding(.trailing, Spacing.tiny)
                .fixedSize(horizontal: true, vertical: false)

            TextField(String.zero, text: textBinding)
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
    @State var value: Double = 10
    @FocusState var focusedField: BuyAssetInputField.FiatField?
    return BuyAssetInputField(value: $value, currencySymbol: "$", focusedField: $focusedField)
}
