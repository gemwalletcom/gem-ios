// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct StateButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public let image: Image?
    public let infoTextValue: TextValue?
    public let variant: ButtonVariant

    private let action: () -> Void

    public init(
        text: String,
        textStyle: TextStyle = StateButton.defaultTextStyle,
        variant: ButtonVariant = .primary(),
        image: Image? = nil,
        infoTitle: String? = nil,
        infoTitleStyle: TextStyle = .calloutSecondary,
        action: @escaping () -> Void
    ) {
        self.textValue = TextValue(text: text, style: textStyle)
        self.variant = variant
        self.infoTextValue = infoTitle.map({ TextValue(text: $0, style: infoTitleStyle) })
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
            Button(action: action) {
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
            .buttonStyle(.variant(variant))
            .disabled(isDisabled)
        }
    }
    
    private var isDisabled: Bool {
        switch variant {
        case .primary(let state): state != .normal
        case .secondary: false
        }
    }
}

public extension ButtonVariant {
    static func primary<T>(
        _ viewState: StateViewType<T>,
        showProgress: Bool = true,
        disabledRule: Bool? = nil
    ) -> Self {
        switch viewState {
        case .loading: return .primary(.loading(showProgress: showProgress))
        case .noData: return .primary(.disabled)
        case .data: return .primary(.normal)
        case .error:
            if let disabledRule, !disabledRule {
                return .primary(.normal)
            }
            return .primary(.disabled)
        }
    }
}

// MARK: - Previews

#Preview {
    List {
        Section(header: Text("Primary · normal")) {
            StateButton(text: "Submit",
                        variant: .primary(),
                        action: {})
            StateButton(text: "Submit",
                        variant: .primary(),
                        image: Images.System.faceid,
                        action: {})
        }

        Section(header: Text("Primary · normal + info")) {
            StateButton(text: "Submit",
                        variant: .primary(),
                        infoTitle: "Approve token",
                        action: {})
            StateButton(text: "Submit",
                        variant: .primary(),
                        image: Images.System.faceid,
                        infoTitle: "Long info title Long info title Long info title",
                        action: {})
        }

        Section(header: Text("Primary · loading")) {
            StateButton(text: "Submit",
                        variant: .primary(.loading()),
                        image: Images.System.faceid,
                        action: {})
        }

        Section(header: Text("Primary · disabled")) {
            StateButton(text: "Submit",
                        variant: .primary(),
                        image: Images.System.faceid,
                        action: {})
                .disabled(true)

            StateButton(text: "Submit",
                        variant: .primary(.disabled),
                        action: {})
        }

        Section(header: Text("Secondary")) {
            StateButton(text: "Insufficient Balance",
                        variant: .secondary,
                        action: {})
            StateButton(text: "Insufficient Balance",
                        variant: .secondary,
                        image: Images.System.faceid,
                        action: {})
        }
    }
    .padding()
}
