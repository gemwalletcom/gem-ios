// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

struct AutocloseInputSection<Field: Hashable>: View {
    @Binding var inputModel: InputValidationViewModel
    let sectionModel: AutocloseViewModel
    let field: Field
    var focusedField: FocusState<Field?>.Binding

    var body: some View {
        Section {
            InputValidationField(
                model: $inputModel,
                placeholder: sectionModel.priceTitle,
                allowClean: true
            )
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused(focusedField, equals: field)
        } header: {
            Text(sectionModel.title)
        } footer: {
            HStack {
                Text(sectionModel.profitTitle)
                Spacer()
                Text(sectionModel.expectedPnL)
                    .foregroundStyle(sectionModel.pnlColor)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
        }
    }
}
