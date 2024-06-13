// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct StatefullButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public var styleState: StatefulButtonStyle.State

    private let action: () -> Void

    public init<T>(
        text: String,
        textStyle: TextStyle = StatefullButton.defaultTextStyle,
        viewState: StateViewType<T>,
        action: @escaping () -> Void
    ) {

        let styleState: StatefulButtonStyle.State
        switch viewState {
        case .noData:
            styleState = .disabled
        case .loaded, .error:
            styleState = .normal
        case .loading:
            styleState = .loading
        }

        self.init(text: text, textStyle: textStyle, styleState: styleState, action: action)
    }

    public init(
        text: String,
        textStyle: TextStyle = StatefullButton.defaultTextStyle,
        styleState: StatefulButtonStyle.State,
        action: @escaping () -> Void
    ) {
        self.textValue = TextValue(text: text, style: textStyle)
        self.styleState = styleState
        self.action = action
    }

    public init(
        textValue: TextValue,
        styleState: StatefulButtonStyle.State,
        action: @escaping () -> Void
    ) {
        self.textValue = textValue
        self.styleState = styleState
        self.action = action
    }

    public var body: some View {
        Button(
            action: action,
            label: {
                Text(textValue.text)
                    .textStyle(textValue.style)
            }
        )
        .buttonStyle(.statefullBlue(state: styleState))
    }
}

// MARK: - Preview

#Preview {
    List {
        Section(header: Text("Normal State")) {
            StatefullButton(text: "Submit", styleState: .normal, action: {})
        }

        Section(header: Text("Loading State")) {
            StatefullButton(text: "Submit", styleState: .loading, action: {})
        }

        Section(header: Text("Disabled State")) {
            StatefullButton(text: "Submit", styleState: .normal, action: {})
                .disabled(true)

            StatefullButton(text: "Submit", styleState: .disabled, action: {})
        }
    }
    .padding()
}
