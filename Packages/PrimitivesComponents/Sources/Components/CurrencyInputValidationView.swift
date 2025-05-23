// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

public struct CurrencyInputValidationView: View {
    @Binding private var model: InputValidationViewModel
    private let config: CurrencyInputConfigurable

    public init(
        model: Binding<InputValidationViewModel>,
        config: CurrencyInputConfigurable
    ) {
        _model  = model
        self.config = config
    }

    public var body: some View {
        VStack(spacing: .small) {
            CurrencyInputView(
                text: $model.text,
                config: config
            )

            if let error = model.error {
                Text(error.localizedDescription)
                    .textStyle(TextStyle(font: .footnote, color: Colors.red))
                    .transition(.opacity)
            }
        }
    }
}
