// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

public struct AddressInputView: View {

    @Binding private var model: AddressInputViewModel

    private let onSelectScan: (@MainActor () -> Void)?

    public init(
        model: Binding<AddressInputViewModel>,
        onSelectScan: (@MainActor () -> Void)? = nil
    ) {
        _model = model
        self.onSelectScan = onSelectScan
    }

    public var body: some View {
        InputValidationField(
            model: $model.inputModel,
            placeholder: model.placeholder,
            allowClean: true,
            trailingView: {
                HStack(spacing: Spacing.medium) {
                    NameRecordView(model: model.nameRecordViewModel)
                    if model.shouldShowInputActions {
                        ListButton(image: Images.System.paste, action: model.onSelectPaste)
                        if let onSelectScan {
                            ListButton(image: Images.System.qrCodeViewfinder, action: onSelectScan)
                        }
                    }
                }
            }
        )
        .keyboardType(.alphabet)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .onChange(of: model.text, model.onTextChange)
        .onChange(of: model.nameResolveState, model.onNameResolveStateChange)
    }
}
