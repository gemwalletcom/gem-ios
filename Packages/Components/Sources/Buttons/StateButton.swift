// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public protocol StateButtonViewable: Sendable {
    var title: String { get }
    var type: ButtonType { get }
    var icon: Image? { get }
    var infoText: String? { get }

    @MainActor func action()
}

extension StateButtonViewable {
    public var infoText: String? { nil }
}

public struct StateButton: View {
    public static let defaultTextStyle = TextStyle(font: .body.weight(.semibold), color: Colors.whiteSolid)

    public let textValue: TextValue
    public let image: Image?
    public let infoTextValue: TextValue?
    public let type: ButtonType

    private let action: () -> Void

    public init(
        text: String,
        textStyle: TextStyle = StateButton.defaultTextStyle,
        type: ButtonType = .primary(),
        image: Image? = nil,
        infoTitle: String? = nil,
        infoTitleStyle: TextStyle = .calloutSecondary,
        truncationMode: Text.TruncationMode = .tail,
        action: @escaping () -> Void
    ) {
        self.textValue = TextValue(text: text, style: textStyle, truncationMode: truncationMode)
        self.type = type
        self.infoTextValue = infoTitle.map({ TextValue(text: $0, style: infoTitleStyle) })
        self.action = action
        self.image = image
    }

    public var body: some View {
        VStack(spacing: .tiny) {
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
                        .truncationMode(textValue.truncationMode)
                }
                .font(textValue.style.font)
            }
            .buttonStyle(.variant(type))
            .disabled(type.isDisabled)
        }
    }
}

public extension StateButton {
    init(_ model: StateButtonViewable) {
        self.init(
            text: model.title,
            type: model.type,
            image: model.icon,
            infoTitle: model.infoText,
            action: model.action
        )
    }
}

public extension ButtonType {
    static func primary<T>(
        _ viewState: StateViewType<T>,
        showProgress: Bool = true,
        isDisabled: Bool? = nil
    ) -> Self {
        if let isDisabled, isDisabled {
            return .primary(.disabled)
        }
        switch viewState {
        case .loading: return .primary(.loading(showProgress: showProgress))
        case .noData: return .primary(.disabled)
        case .data: return .primary(.normal)
        case .error: 
            if let isDisabled, !isDisabled {
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
                        type: .primary(),
                        action: {})
            StateButton(text: "Submit",
                        type: .primary(),
                        image: Images.System.faceid,
                        action: {})
        }

        Section(header: Text("Primary · normal + info")) {
            StateButton(text: "Submit",
                        type: .primary(),
                        infoTitle: "Approve token",
                        action: {})
            StateButton(text: "Submit",
                        type: .primary(),
                        image: Images.System.faceid,
                        infoTitle: "Long info title Long info title Long info title",
                        action: {})
        }

        Section(header: Text("Primary · loading")) {
            StateButton(text: "Submit",
                        type: .primary(.loading()),
                        image: Images.System.faceid,
                        action: {})
        }

        Section(header: Text("Primary · disabled")) {
            StateButton(text: "Submit",
                        type: .primary(),
                        image: Images.System.faceid,
                        action: {})
                .disabled(true)

            StateButton(text: "Submit",
                        type: .primary(.disabled),
                        action: {})
        }
    }
    .padding()
}
