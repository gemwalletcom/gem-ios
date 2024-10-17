// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ColorButtonStyle: ButtonStyle {
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let foregroundStyle: Color
    let foregroundStylePressed: Color
    let background: Color
    let backgroundPressed: Color

    public init(
        paddingHorizontal: CGFloat,
        paddingVertical: CGFloat,
        foregroundStyle: Color,
        foregroundStylePressed: Color,
        background: Color,
        backgroundPressed: Color
    ) {
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.foregroundStyle = foregroundStyle
        self.foregroundStylePressed = foregroundStylePressed
        self.background = background
        self.backgroundPressed = backgroundPressed
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
        return RoundedRectangle(cornerRadius: 12)
            .fill(configuration.isPressed ? backgroundPressed : background)
    }

    private func foregroundStyle(configuration: Configuration) -> some ShapeStyle {
        return configuration.isPressed ? foregroundStylePressed : foregroundStyle
    }
}

// MARK: - ColorButtonStyle Static

extension ButtonStyle where Self == ColorButtonStyle {
    public static func blue(
        paddingHorizontal: CGFloat = Spacing.medium,
        paddingVertical: CGFloat = Spacing.medium) -> ColorButtonStyle
    {
        return ColorButtonStyle(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.blue,
            backgroundPressed: Colors.blueDark
        )
    }

    public static func blueGrayPressed(
        paddingHorizontal: CGFloat = Spacing.medium,
        paddingVertical: CGFloat = Spacing.medium) -> ColorButtonStyle {
            return ColorButtonStyle(
                paddingHorizontal: paddingHorizontal,
                paddingVertical: paddingVertical,
                foregroundStyle: Colors.whiteSolid,
                foregroundStylePressed: Colors.whiteSolid,
                background: Colors.blue,
                backgroundPressed: Colors.gray
            )
        }

    public static func gray(
        paddingHorizontal: CGFloat = Spacing.medium,
        paddingVertical: CGFloat = Spacing.medium) -> ColorButtonStyle {
            return ColorButtonStyle(
                paddingHorizontal: paddingHorizontal,
                paddingVertical: paddingVertical,
                foregroundStyle: Colors.whiteSolid,
                foregroundStylePressed: Colors.whiteSolid,
                background: Colors.grayLight,
                backgroundPressed: Colors.gray
            )
        }

    public static func lightGray(
        paddingHorizontal: CGFloat = Spacing.medium,
        paddingVertical: CGFloat = Spacing.medium) -> ColorButtonStyle {
            return ColorButtonStyle(
                paddingHorizontal: paddingHorizontal,
                paddingVertical: paddingVertical,
                foregroundStyle: Colors.gray,
                foregroundStylePressed: Colors.whiteSolid,
                background: Colors.grayVeryLight,
                backgroundPressed: Colors.grayLight
            )
        }

    public static func white(
        paddingHorizontal: CGFloat = Spacing.medium,
        paddingVertical: CGFloat = Spacing.medium) -> ColorButtonStyle {
            return ColorButtonStyle(
                paddingHorizontal: paddingHorizontal,
                paddingVertical: paddingVertical,
                foregroundStyle: Colors.whiteSolid,
                foregroundStylePressed: Colors.whiteSolid,
                background: Colors.white,
                backgroundPressed: Colors.grayVeryLight
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
                .frame(height: StateButtonStyle.maxButtonHeight)

            if state.showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Colors.whiteSolid))
            } else {
                configuration.label
                    .lineLimit(1)
                    .foregroundStyle(foregroundStyle(configuration: configuration))
                    .padding(.horizontal, Spacing.medium)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: StateButtonStyle.maxButtonHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        switch state {
        case .normal:
            configuration.isPressed ? backgroundPressed : background
        case .loading(let showProgress):
            showProgress ? background : backgroundPressed
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
    public static func statefullBlue(state: StateButtonStyle.State) -> StateButtonStyle {
        StateButtonStyle(
            state: state,
            foregroundStyle: Colors.whiteSolid,
            foregroundStylePressed: Colors.whiteSolid,
            background: Colors.blue,
            backgroundPressed: Colors.blueDark,
            backgroundDisabled: Colors.gray
        )
    }
}


// MARK: - Previews

#Preview {
    struct StatefulButtonPreviewWrapper: View {
        let text: String
        @State var state: StateButtonStyle.State

        var body: some View {
            Button(action: {
                state = .loading(showProgress: state.showProgress)
                Task {
                    try await Task.sleep(nanoseconds: 1000000000 * 3)
                    state = .normal
                }
            }) {
                Text(text)
            }
            .buttonStyle(.statefullBlue(state: state))
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
                Text("White Button")
            }
            .buttonStyle(.white())

            Button(action: {}) {
                Text("Clear Button")
            }
            .buttonStyle(.clear)
            .frame(maxWidth: Spacing.scene.button.maxWidth)

            Button(action: {}) {
                Text("ClearBlue Button")
            }
            .buttonStyle(.clearBlue)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }

        Section(header: Text("Stateful Buttons")) {
            StatefulButtonPreviewWrapper(text: "Stateful Button", state: .normal)

            StatefulButtonPreviewWrapper(text: "BIG TEXT Disabled Button BIG TEXT Disabled Button", state: .normal)
                .disabled(true)

            StatefulButtonPreviewWrapper(text: "Stateful Button", state: .disabled)
                .disabled(true)

            StatefulButtonPreviewWrapper(text: "Stateful Button", state: .loading(showProgress: true))
                .disabled(false)

            StatefulButtonPreviewWrapper(text: "Stateful Button", state: .loading(showProgress: false))
                .disabled(false)
        }
    }
    .padding()
}
