// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct StateButtonStyle: ButtonStyle {
    public static let maxHeight: CGFloat = 50
    private let variant: ButtonType
    private let palette: ButtonStylePalette

    public init(_ variant: ButtonType, palettee: ButtonStylePalette) {
        self.variant = variant
        self.palette = palettee
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            adoptiveShape(configuration: configuration)

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
    
    @ViewBuilder
    private func adoptiveShape(configuration: Configuration) -> some View {
        if #available(iOS 26, *) {
            DefaultGlassEffectShape()
                .fill(background(configuration: configuration))
                .frame(maxHeight: Self.maxHeight)
                .glassEffect(.regular.interactive(!variant.isDisabled))
        } else {
            RoundedRectangle(cornerRadius: Sizing.space12)
                .fill(background(configuration: configuration))
                .frame(maxHeight: Self.maxHeight)
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

// MARK: - ButtonStyle Static

extension ButtonStyle where Self == StateButtonStyle {
    public static func primary(_ state: ButtonState = .normal) -> Self {
        .init(.primary(state), palettee: .primary)
    }

    public static func variant(_ variant: ButtonType) -> Self {
        switch variant {
        case .primary(let state): .primary(state)
        }
    }
}

// MARK: - Previews

#Preview {
    List {
        Section("Helpers .primary") {
            Button("Primary · normal")  { }
                .buttonStyle(.primary())
            Button("Primary · loading") { }
                .buttonStyle(.primary(.loading()))
            Button("Primary · disabled"){ }
                .buttonStyle(.primary(.disabled))
        }
    }
    .padding()
}
