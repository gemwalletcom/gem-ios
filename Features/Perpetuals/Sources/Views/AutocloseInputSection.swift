// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

struct AutocloseInputSection<Field: Hashable>: View {
    @Binding var inputModel: InputValidationViewModel
    let title: String
    let placeholder: String
    let pnlTitle: String
    let pnlText: String
    let pnlColor: Color
    let field: Field
    var focusedField: FocusState<Field?>.Binding

    var body: some View {
        Section {
            InputValidationField(
                model: $inputModel,
                placeholder: placeholder,
                allowClean: true
            )
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused(focusedField, equals: field)
        } header: {
            Text(title)
        } footer: {
            HStack {
                Text(pnlTitle)
                Spacer()
                Text(pnlText)
                    .foregroundStyle(pnlColor)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
        }
    }
}
