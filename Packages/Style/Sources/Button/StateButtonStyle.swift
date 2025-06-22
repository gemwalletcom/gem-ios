// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct StateButtonStyle: ButtonStyle {
    public static let maxHeight: CGFloat = 50
    private let variant: ButtonVariant
    private let palette: ButtonStylePalette

    public init(_ variant: ButtonVariant, palettee: ButtonStylePalette) {
        self.variant = variant
        self.palette = palettee
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(background(configuration: configuration))
                .frame(maxHeight: Self.maxHeight)

            if variant.state.showProgress {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Colors.whiteSolid)
            } else {
                configuration.label
                    .lineLimit(1)
                    .foregroundStyle(foreground(configuration: configuration))
                    .padding(.horizontal, .medium)
                    .frame(maxWidth: .infinity, maxHeight: Self.maxHeight)
            }
        }
    }

    private func background(configuration: Configuration) -> Color {
        switch variant.state {
        case .normal: configuration.isPressed ? palette.backgroundPressed : palette.background
        case .loading(let show): show ? palette.background : palette.backgroundDisabled
        case .disabled: palette.backgroundDisabled
        }
    }

    private func foreground(configuration: Configuration) -> Color {
        switch variant.state {
        case .normal: configuration.isPressed ? palette.foregroundPressed : palette.foreground
        case .loading(let show): show ? palette.foreground : palette.foreground.opacity(0.65)
        case .disabled: palette.foreground
        }
    }
}

// MARK: - ButtonStyle

extension ButtonStyle where Self == StateButtonStyle {
    public static func primary(_ state: ButtonState = .normal) -> Self {
        .init(.primary(state), palettee: .primary)
    }

    public static func secondary() -> Self {
        .init(.secondary, palettee: .secondary)
    }

    public static func variant(_ variant: ButtonVariant) -> Self {
        switch variant {
        case .primary(let state): .primary(state)
        case .secondary: .secondary()
        }
    }
}

// MARK: - Previews

#Preview {
    List {
        Section("Helpers .primary / .secondary") {
            Button("Primary · normal")  { }
                .buttonStyle(.primary())
            Button("Primary · loading") { }
                .buttonStyle(.primary(.loading()))
            Button("Primary · disabled"){ }
                .buttonStyle(.primary(.disabled))
            Button("Secondary") { }
                .buttonStyle(.secondary())
        }
    }
    .padding()
}
