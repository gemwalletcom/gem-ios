// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct InputValidationField<TrailingView: View>: View {
    @Binding private var model: InputValidationViewModel

    let style: FloatFieldStyle
    let placeholder: String
    let allowClean: Bool

    private let trailingView: TrailingView

    public init(
        model: Binding<InputValidationViewModel>,
        style: FloatFieldStyle = .standard,
        placeholder: String,
        allowClean: Bool = true,
        @ViewBuilder trailingView: () -> TrailingView = { EmptyView() }
    ) {
        self.trailingView = trailingView()
        _model = model
        self.style = style
        self.placeholder = placeholder
        self.allowClean = allowClean
    }

    public var body: some View {
        Group {
            FloatTextField(
                placeholder,
                text: $model.text,
                style: style,
                allowClean: allowClean,
                trailingView: {
                    trailingView
                }
            )

            if let message = model.error?.localizedDescription {
                Text(message)
                    .textStyle(TextStyle(font: .footnote, color: Colors.red))
                    .transition(.opacity)
            }
        }
    }
}
