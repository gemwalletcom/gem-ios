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
            .foregroundStyle(configuration.isPressed ? foregroundStylePressed : foregroundStyle)
            .background(configuration.isPressed ? backgroundPressed : background)
            .cornerRadius(12)
            .fontWeight(.semibold)
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
            foregroundStyle: Colors.whiteSolid,
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
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(configuration.isPressed ? Colors.gray : Colors.black)
    }
}

// MARK: - ClearButtonStyle Static

extension ButtonStyle where Self == ClearButtonStyle {
    public static var clear: ClearButtonStyle { ClearButtonStyle() }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 16) {
        Button(action: {}) {
            Text("Blue Button")
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
    }
    .padding()
}
