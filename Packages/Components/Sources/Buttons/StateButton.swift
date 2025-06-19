// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct StateButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public let image: Image?
    public let infoTextValue: TextValue?
    public let kind: StateButtonStyle.Kind

    private let action: () -> Void

    public init<T>(
        text: String,
        textStyle: TextStyle = StateButton.defaultTextStyle,
        viewState: StateViewType<T>,
        showProgressIndicator: Bool = true,
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
                return .loading(showProgress: showProgressIndicator)
            case .data:
                return .normal
            case .error:
                if let disabledRule {
                    return disabledRule ? .disabled : .normal
                } else {
                    return .disabled
                }
            }
        }()

        self.init(text: text,
                  textStyle: textStyle,
                  kind: .primary(styleState),
                  image: image,
                  infoTitle: infoTitle,
                  infoTitleStyle: infoTitleStyle,
                  action: action
        )
    }

    public init(
        text: String,
        textStyle: TextStyle = StateButton.defaultTextStyle,
        kind: StateButtonStyle.Kind,
        image: Image? = nil,
        infoTitle: String? = nil,
        infoTitleStyle: TextStyle = .calloutSecondary,
        action: @escaping () -> Void
    ) {
        self.textValue = TextValue(text: text, style: textStyle)
        self.kind = kind
        self.infoTextValue = infoTitle.map({ TextValue(text: $0, style: infoTitleStyle) })
        self.action = action
        self.image = image
    }

    private var isDisabled: Bool {
        switch kind {
        case .primary(let state): state != .normal
        case .secondary: false
        }
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
                                .foregroundStyle(textValue.style.color)
                        }
                        Text(textValue.text)
                            .foregroundStyle(textValue.style.color)
                    }
                    .font(textValue.style.font)
                }
            )
            .disabled(isDisabled)
            .buttonStyle(.statefull(kind: kind))
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        // Primary
        Section(header: Text("Normal State")) {
            StateButton(text: "Submit", kind: .primary(.normal), action: {})
            StateButton(text: "Submit", kind: .primary(.normal), image: Images.System.faceid, action: {})
        }

        Section(header: Text("Normal State with info")) {
            StateButton(text: "Submit", kind: .primary(.normal), infoTitle: "Approve token", action: {})
            StateButton(text: "Submit", kind: .primary(.normal), image: Images.System.faceid, infoTitle: "Big info titleBig info titleBig info titleBig info titleBig info titleBig info titleBig info title", action: {})
        }

        Section(header: Text("Loading State")) {
            StateButton(
                text: "Submit",
                kind: .primary(.loading(showProgress: true)),
                image: Images.System.faceid,
                action: {}
            )
        }

        Section(header: Text("Disabled State")) {
            StateButton(
                text: "Submit",
                kind: .primary(.normal),
                image: Images.System.faceid, action: {}
            )
            .disabled(true)
            StateButton(text: "Submit", kind: .primary(.disabled), action: {})
        }

        // Secondary
        StateButton(
            text: "Insufficient Balance",
            kind: .secondary,
            action: {}
        )
        StateButton(
            text: "Insufficient Balance",
            kind: .secondary,
            image: Images.System.faceid,
            action: {}
        )
    }
    .padding()
}
