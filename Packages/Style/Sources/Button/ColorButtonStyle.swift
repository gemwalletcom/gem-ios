// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ColorButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let palette: ButtonStylePalette
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let cornerRadius: CGFloat
    let isGlassEffectEnabled: Bool

    public init(
        palette: ButtonStylePalette,
        paddingHorizontal: CGFloat,
        paddingVertical: CGFloat,
        cornerRadius: CGFloat,
        isGlassEffectEnabled: Bool
    ) {
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.palette = palette
        self.cornerRadius = cornerRadius
        self.isGlassEffectEnabled = isGlassEffectEnabled
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

    @ViewBuilder
    private func background(configuration: Configuration) -> some View {
        if #available(iOS 26, *), isGlassEffectEnabled {
            DefaultGlassEffectShape()
                .fill(palette.background)
                .glassEffect(.regular.interactive(isEnabled))
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(configuration.isPressed ? palette.backgroundPressed : palette.background)
        }
    }

    private func foregroundStyle(configuration: Configuration) -> some ShapeStyle {
        configuration.isPressed ? palette.foregroundPressed : palette.foreground
    }
}

// MARK: - ButtonStyle Static

extension ButtonStyle where Self == ColorButtonStyle {
    public static func blue(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .blue,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }

    public static func blueGrayPressed(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .blueGrayPressed,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }
    

    public static func gray(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .gray,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }

    public static func lightGray(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .lightGray,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }

    public static func white(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .white,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }

    public static func empty(
        paddingHorizontal: CGFloat = .small + .space4,
        paddingVertical: CGFloat = .small,
        cornerRadius: CGFloat = .small,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .empty,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }

    public static func amount(
        paddingHorizontal: CGFloat = .small,
        paddingVertical: CGFloat = .small,
        cornerRadius: CGFloat = .small,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .amount,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }

    public static func listStyleColor(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .listStyleColor,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }
    
    public static func red(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .red,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }
    
    public static func green(
        paddingHorizontal: CGFloat = .medium,
        paddingVertical: CGFloat = .medium,
        cornerRadius: CGFloat = Sizing.space12,
        isGlassEffectEnabled: Bool = false
    ) -> ColorButtonStyle {
        ColorButtonStyle(
            palette: .green,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            cornerRadius: cornerRadius,
            isGlassEffectEnabled: isGlassEffectEnabled
        )
    }
}

// MARK: – Previews

#Preview {
    List {
        Section("ColorButtonStyle presets") {
            Button("Blue"){}
                .buttonStyle(.blue())
            Button("Blue Gray Pressed"){}
                .buttonStyle(.blueGrayPressed())
            Button("Gray"){}
                .buttonStyle(.gray())
            Button("Light Gray"){}
                .buttonStyle(.lightGray())
            Button("List Style Color"){}
                .buttonStyle(.listStyleColor())
            Button("White"){}
                .buttonStyle(.white())
            Button("Empty"){}
                .buttonStyle(.empty())
            Button("Amount"){}
                .buttonStyle(.amount())
        }
    }
    .padding()
}
