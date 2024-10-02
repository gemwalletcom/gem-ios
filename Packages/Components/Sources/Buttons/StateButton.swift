// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct StateButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public let image: Image?
    public let infoTextValue: TextValue?
    public let styleState: StateButtonStyle.State

    private let action: () -> Void

    public init<T>(
        text: String,
        textStyle: TextStyle = StateButton.defaultTextStyle,
        viewState: StateViewType<T>,
        image: Image? = nil,
        infoTitle: String? = nil,
        infoTitleStyle: TextStyle = .calloutSecondary,
        disabledRule: Bool? = nil,
        action: @escaping () -> Void
    ) {

        let styleState: StateButtonStyle.State = {
            switch viewState {
            case .noData:
                return .disabled
            case .loading:
                return .loading
            case .loaded:
                return .normal
            case .error:
                if let disabledRule {
                    return disabledRule ? .disabled : .normal
                } else {
                    return .disabled
                }
            }
        }()

        self.init(text: text, textStyle: textStyle, styleState: styleState, image: image, infoTitle: infoTitle, infoTitleStyle: infoTitleStyle, action: action)
    }

    public init(
        text: String,
        textStyle: TextStyle = StateButton.defaultTextStyle,
        styleState: StateButtonStyle.State,
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
    }

    public init(
        textValue: TextValue,
        styleState: StateButtonStyle.State,
        infoTextValue: TextValue? = nil,
        image: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.textValue = textValue
        self.styleState = styleState
        self.infoTextValue = infoTextValue
        self.action = action
        self.image = image
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
            .disabled(styleState == .disabled)
            .buttonStyle(.statefullBlue(state: styleState))
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        Section(header: Text("Normal State")) {
            StateButton(text: "Submit", styleState: .normal, action: {})
            StateButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), action: {})
        }

        Section(header: Text("Normal State with info")) {
            StateButton(text: "Submit", styleState: .normal, infoTitle: "Approve token", action: {})
            StateButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), infoTitle: "Big info titleBig info titleBig info titleBig info titleBig info titleBig info titleBig info title", action: {})
        }

        Section(header: Text("Loading State")) {
            StateButton(text: "Submit", styleState: .loading, image: Image(systemName: SystemImage.faceid), action: {})
        }

        Section(header: Text("Disabled State")) {
            StateButton(text: "Submit", styleState: .normal, image: Image(systemName: SystemImage.faceid), action: {})
                .disabled(true)

            StateButton(text: "Submit", styleState: .disabled, action: {})
        }
    }
    .padding()
}
