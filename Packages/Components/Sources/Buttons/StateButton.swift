// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct StatefullButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public let image: Image?
    public let infoTextValue: TextValue?
    public var styleState: StatefulButtonStyle.State
    public var isDisabled: Bool

    private let action: () -> Void

    public init<T>(
        text: String,
        textStyle: TextStyle = StatefullButton.defaultTextStyle,
        viewState: StateViewType<T>,
        image: Image? = nil,
        infoTitle: String? = nil,
        infoTitleStyle: TextStyle = .calloutSecondary,
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

        self.init(text: text, textStyle: textStyle, styleState: styleState, image: image, infoTitle: infoTitle, infoTitleStyle: infoTitleStyle, action: action)
    }

    public init(
        text: String,
        textStyle: TextStyle = StatefullButton.defaultTextStyle,
        styleState: StatefulButtonStyle.State,
        image: Image? = nil,
        infoTitle: String? = nil,
        infoTitleStyle: TextStyle = .calloutSecondary,
        action: @escaping () -> Void
    ) {
        self.textValue = TextValue(text: text, style: textStyle)
        self.styleState = styleState
        if let infoTitle {
            self.infoTextValue = TextValue(text: infoTitle, style: infoTitleStyle)
        } else {
            self.infoTextValue = nil
        }
        self.action = action
        self.image = image
        self.isDisabled = styleState == .disabled
    }

    public init(
        textValue: TextValue,
        styleState: StatefulButtonStyle.State,
        infoTextValue: TextValue? = nil,
        image: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.textValue = textValue
        self.styleState = styleState
        self.infoTextValue = infoTextValue
        self.action = action
        self.image = image
        self.isDisabled = styleState == .disabled
    }

    public var body: some View {
        VStack {
            if let infoTextValue {
                Text(infoTextValue.text)
                    .textStyle(infoTextValue.style)
                    .multilineTextAlignment(.center)
            }
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
}

// MARK: - Preview

#Preview {
    List {
        Section(header: Text("Normal State")) {
            StatefullButton(text: "Submit", styleState: .normal, action: {})
            StatefullButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), action: {})
        }

        Section(header: Text("Normal State with info")) {
            StatefullButton(text: "Submit", styleState: .normal, infoTitle: "Approve token", action: {})
            StatefullButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), infoTitle: "Big info titleBig info titleBig info titleBig info titleBig info titleBig info titleBig info title", action: {})
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
