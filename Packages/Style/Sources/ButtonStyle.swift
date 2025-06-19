// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ColorButtonStyle: ButtonStyle {
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let foregroundStyle: Color
    let foregroundStylePressed: Color
    let background: Color
    let backgroundPressed: Color
    let cornerRadius: CGFloat

    public init(
        paddingHorizontal: CGFloat,
        paddingVertical: CGFloat,
        foregroundStyle: Color,
        foregroundStylePressed: Color,
        background: Color,
        backgroundPressed: Color,
        cornerRadius: CGFloat
    ) {
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.foregroundStyle = foregroundStyle
        self.foregroundStylePressed = foregroundStylePressed
        self.background = background
        self.backgroundPressed = backgroundPressed
        self.cornerRadius = cornerRadius
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, paddingVertical)
            .padding(.horizontal, paddingHorizontal)
            .foregroundStyle(foregroundStyle(configuration: configuration))
            .background(background(configuration: configuration))
            .fontWeight(.semibold)
    }

    private func background(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(configuration.isPressed ? backgroundPressed : background)
    }

    private func foregroundStyle(configuration: Configuration) -> some ShapeStyle {
        configuration.isPressed ? foregroundStylePressed : foregroundStyle
    }
}

// MARK: - ColorButtonStyle Static

extension ButtonStyle where Self == ColorButtonStyle {
    public static func blue(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = 12
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.blue,
            backgroundPressed: Colors.blueDark,
            cornerRadius: cornerRadius
        )
    }

    public static func blueGrayPressed(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = 12
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.blue,
            backgroundPressed: Colors.gray,
            cornerRadius: cornerRadius
        )
    }

    public static func gray(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = 12
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.grayLight,
            backgroundPressed: Colors.gray,
            cornerRadius: cornerRadius
        )
    }

    public static func lightGray(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = 12
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.gray,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.grayVeryLight,
            backgroundPressed: Colors.grayLight.opacity(0.3),
            cornerRadius: cornerRadius
        )
    }

    public static func white(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = 12
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.white,
            backgroundPressed: Colors.grayVeryLight,
            cornerRadius: cornerRadius
        )
    }

    public static func empty(
        paddingHorizontal: CGFloat = .small + .space4,
        paddingVertical: CGFloat = .small,
        cornerRadius: CGFloat = .small
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.black,
            foregroundStylePressed: Colors.black.opacity(0.5),
            background: Colors.Empty.buttonsBackground,
            backgroundPressed: Colors.Empty.buttonsBackground.opacity(0.5),
            cornerRadius: cornerRadius
        )
    }

    public static func amount(
        paddingHorizontal: CGFloat = .small,
        paddingVertical: CGFloat = .small,
        cornerRadius: CGFloat = .small
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.black,
            foregroundStylePressed: Colors.black.opacity(0.5),
            background: Colors.grayVeryLight,
            backgroundPressed: Colors.grayVeryLight.opacity(0.5),
            cornerRadius: cornerRadius
        )
    }
    
    public static func listStyleColor(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = 12
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.gray,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.listStyleColor,
            backgroundPressed: Colors.grayVeryLight,
            cornerRadius: cornerRadius
        )
    }
}

public struct ClearButtonStyle: ButtonStyle {
    let foregroundStyle: Color
    let foregroundStylePressed: Color

    public init(foregroundStyle: Color, foregroundStylePressed: Color) {
        self.foregroundStyle = foregroundStyle
        self.foregroundStylePressed = foregroundStylePressed
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(configuration.isPressed ? foregroundStylePressed : foregroundStyle)
    }
}

// MARK: - ClearButtonStyle Static

extension ButtonStyle where Self == ClearButtonStyle {
    public static var clear: ClearButtonStyle { ClearButtonStyle(foregroundStyle: Colors.black, foregroundStylePressed: Colors.gray) }
    public static var clearBlue: ClearButtonStyle { ClearButtonStyle(foregroundStyle: Colors.blue, foregroundStylePressed: Colors.blueDark) }
}

public struct StateButtonStyle: ButtonStyle {
    public static let maxButtonHeight: CGFloat = 50

    public enum Kind {
        case primary(State)
        case secondary
    }

    public enum State: Hashable, Equatable {
        case normal
        case loading(showProgress: Bool)
        case disabled

        var showProgress: Bool {
            switch self {
            case .normal, .disabled: false
            case .loading(let showProgress): showProgress
            }
        }
    }

    var state: State
    let foregroundStyle: Color
    let foregroundStylePressed: Color
    let background: Color
    let backgroundPressed: Color
    let backgroundDisabled: Color

    public init(
        state: State,
        foregroundStyle: Color,
        foregroundStylePressed: Color,
        background: Color,
        backgroundPressed: Color,
        backgroundDisabled: Color
    ) {
        self.foregroundStyle = foregroundStyle
        self.foregroundStylePressed = foregroundStylePressed
        self.background = background
        self.backgroundPressed = backgroundPressed
        self.state = state
        self.backgroundDisabled = backgroundDisabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor(configuration: configuration))
                .frame(maxHeight: StateButtonStyle.maxButtonHeight)

            if state.showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Colors.whiteSolid))
            } else {
                configuration.label
                    .lineLimit(1)
                    .foregroundStyle(foregroundStyle(configuration: configuration))
                    .padding(.horizontal, .medium)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(maxHeight: StateButtonStyle.maxButtonHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        switch state {
        case .normal:
            configuration.isPressed ? backgroundPressed : background
        case .loading(let showProgress):
            showProgress ? background : backgroundDisabled
        case .disabled:
            backgroundDisabled
        }
    }

    private func foregroundStyle(configuration: Configuration) -> some ShapeStyle {
        switch state {
        case .normal:
            configuration.isPressed ? foregroundStylePressed : foregroundStyle
        case .loading(let showProgress):
            foregroundStylePressed.opacity(showProgress ? 1.0 : 0.65)
        case .disabled:
            foregroundStyle
        }
    }
}

// MARK: - StatefulButtonStyle Static

extension ButtonStyle where Self == StateButtonStyle {
    public static func statefull(kind: StateButtonStyle.Kind) -> StateButtonStyle {
        switch kind {
        case .primary(let state): StateButtonStyle(
            state: state,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.blue,
            backgroundPressed: Colors.blueDark,
            backgroundDisabled: Colors.blueDark.opacity(0.6)
        )
        case .secondary: StateButtonStyle(
            state: .normal,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.blueSecondary,
            backgroundPressed: Colors.blueSecondaryHover,
            backgroundDisabled: Colors.blueSecondary
        )
        }
    }
}

// MARK: - Previews

#Preview {
    struct StatefulButtonPreviewWrapper: View {
        let text: String
        @State var kind: StateButtonStyle.Kind

        var body: some View {
            Button(action: {
                switch kind {
                case .primary(let state):
                    kind = .primary(.loading(showProgress: state.showProgress))
                    Task {
                        try await Task.sleep(nanoseconds: 1000000000 * 3)
                        kind = .primary(.normal)
                    }
                case .secondary:
                    break
                }
            }) {
                Text(text)
            }
            .buttonStyle(.statefull(kind: kind))
        }
    }

    return List {
        Section(header: Text("Regular Buttons")) {
            Button(action: {}) {
                Text("Blue Button")
            }
            .buttonStyle(.blue())

            Button(action: {}) {
                Text("Blue BIG TEXT TEXT Button Blue BIG TEXT TEXT Button Blue BIG TEXT TEXT Button")
            }
            .buttonStyle(.blue())

            Button(action: {}) {
                Text("Blue Gray Pressed Button")
            }
            .buttonStyle(.blueGrayPressed())

            Button(action: {}) {
                Text("Gray Button")
            }
            .buttonStyle(.gray())

            Button(action: {}) {
                Text("Light Gray Button")
            }
            .buttonStyle(.lightGray())
            
            Button(action: {}) {
                Text("List Style Color Button")
            }
            .buttonStyle(.listStyleColor())

            Button(action: {}) {
                Text("White Button")
            }
            .buttonStyle(.white())

            Button(action: {}) {
                Text("Clear Button")
            }
            .buttonStyle(.clear)
            .frame(maxWidth: .scene.button.maxWidth)

            Button(action: {}) {
                Text("ClearBlue Button")
            }
            .buttonStyle(.clearBlue)
            .frame(maxWidth: .scene.button.maxWidth)
        }

        Section(header: Text("Stateful Buttons")) {
            StatefulButtonPreviewWrapper(text: "Stateful Button", kind: .primary(.normal))

            StatefulButtonPreviewWrapper(text: "BIG TEXT Disabled Button BIG TEXT Disabled Button", kind: .primary(.normal))
                .disabled(true)

            StatefulButtonPreviewWrapper(text: "Stateful Button", kind: .primary(.disabled))
                .disabled(true)

            StatefulButtonPreviewWrapper(text: "Stateful Button", kind: .primary(.loading(showProgress: true)))
                .disabled(false)

            StatefulButtonPreviewWrapper(text: "Stateful Button", kind: .primary(.loading(showProgress: false)))
                .disabled(false)

            StatefulButtonPreviewWrapper(text: "Secondary State Button", kind: .secondary)
        }
    }
    .padding()
}
