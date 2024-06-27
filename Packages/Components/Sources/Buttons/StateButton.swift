// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct StatefullButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public let image: Image?
    public var styleState: StatefulButtonStyle.State
    public var isDisabled: Bool

    private let action: () -> Void

    public init<T>(
        text: String,
        textStyle: TextStyle = StatefullButton.defaultTextStyle,
        viewState: StateViewType<T>,
        image: Image? = nil,
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

        self.init(text: text, textStyle: textStyle, styleState: styleState, image: image, action: action)
    }

    public init(
        text: String,
        textStyle: TextStyle = StatefullButton.defaultTextStyle,
        styleState: StatefulButtonStyle.State,
        image: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.textValue = TextValue(text: text, style: textStyle)
        self.styleState = styleState
        self.action = action
        self.image = image
        self.isDisabled = styleState == .disabled
    }

    public init(
        textValue: TextValue,
        styleState: StatefulButtonStyle.State,
        image: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.textValue = textValue
        self.styleState = styleState
        self.action = action
        self.image = image
        self.isDisabled = styleState == .disabled
    }

    public var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    if let image {
                        image
                            .font(textValue.style.font)
                            .foregroundStyle(textValue.style.color)
                    }
                    Text(textValue.text)
                        .textStyle(textValue.style)
                }
            }
        )
        .buttonStyle(.statefullBlue(state: styleState))
        .disabled(isDisabled || styleState == .loading)
    }
}

// MARK: - Preview

#Preview {
    List {
        Section(header: Text("Normal State")) {
            StatefullButton(text: "Submit", styleState: .normal, action: {})
            StatefullButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), action: {})
        }

        Section(header: Text("Loading State")) {
            StatefullButton(text: "Submit", styleState: .loading, image: Image(systemName: SystemImage.faceid), action: {})
        }

        Section(header: Text("Disabled State")) {
            StatefullButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), action: {})
                .disabled(true)

            StatefullButton(text: "Submit", styleState: .disabled, action: {})
        }
    }
    .padding()
}
