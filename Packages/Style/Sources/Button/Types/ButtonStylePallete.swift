// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ButtonStylePalette: Hashable, Sendable {
    public let foreground: Color
    public let foregroundPressed: Color
    public let background: Color
    public let backgroundPressed: Color
    public let backgroundDisabled: Color

    public init(
        foreground: Color,
        foregroundPressed: Color,
        background: Color,
        backgroundPressed: Color,
        backgroundDisabled: Color
    ) {
        self.foreground = foreground
        self.foregroundPressed = foregroundPressed
        self.background = background
        self.backgroundPressed = backgroundPressed
        self.backgroundDisabled = backgroundDisabled
    }
}

// MARK: - Static

extension ButtonStylePalette {
    static let primary = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blue,
        backgroundPressed: Colors.blueDark,
        backgroundDisabled: Colors.blueDark.opacity(0.6)
    )

    static let secondary = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blueSecondary,
        backgroundPressed: Colors.blueSecondaryHover,
        backgroundDisabled: Colors.blueSecondary.opacity(0.6)
    )

    static let blue = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blue,
        backgroundPressed: Colors.blueDark,
        backgroundDisabled: .clear
    )

    static let blueGrayPressed = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blue,
        backgroundPressed: Colors.gray,
        backgroundDisabled: .clear
    )

    static let gray = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.grayLight,
        backgroundPressed: Colors.gray,
        backgroundDisabled: .clear
    )

    static let lightGray = ButtonStylePalette(
        foreground: Colors.gray,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.grayVeryLight,
        backgroundPressed: Colors.grayLight.opacity(0.3),
        backgroundDisabled: .clear
    )

    static let white = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.white,
        backgroundPressed: Colors.grayVeryLight,
        backgroundDisabled: .clear
    )

    static let empty = ButtonStylePalette(
        foreground: Colors.black,
        foregroundPressed: Colors.black.opacity(0.5),
        background: Colors.Empty.buttonsBackground,
        backgroundPressed: Colors.Empty.buttonsBackground.opacity(0.5),
        backgroundDisabled: .clear
    )

    static let amount = ButtonStylePalette(
        foreground: Colors.black,
        foregroundPressed: Colors.black.opacity(0.5),
        background: Colors.grayVeryLight,
        backgroundPressed: Colors.grayVeryLight.opacity(0.5),
        backgroundDisabled: .clear
    )

    static let listStyleColor = ButtonStylePalette(
        foreground: Colors.gray,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.listStyleColor,
        backgroundPressed: Colors.grayVeryLight,
        backgroundDisabled: .clear
    )

}
// MARK: – Preview
private struct PaletteSwatch: View {
    let palette: ButtonStylePalette
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(width: 90, alignment: .leading)

            // normal
            RoundedRectangle(cornerRadius: 4)
                .fill(palette.background)
                .frame(width: 32, height: 20)

            // pressed / hover
            RoundedRectangle(cornerRadius: 4)
                .fill(palette.backgroundPressed)
                .frame(width: 32, height: 20)

            // disabled (only visible for primary/secondary)
            RoundedRectangle(cornerRadius: 4)
                .fill(palette.backgroundDisabled)
                .frame(width: 32, height: 20)
        }
        .font(.caption)
    }
}

#Preview {
    List {
        Section("State-button palettes") {
            PaletteSwatch(palette: .primary, title: "Primary")
            PaletteSwatch(palette: .secondary, title: "Secondary")
        }

        Section("Color-button palettes") {
            PaletteSwatch(palette: .blue, title: "Blue")
            PaletteSwatch(palette: .blueGrayPressed, title: "BlueGray")
            PaletteSwatch(palette: .gray, title: "Gray")
            PaletteSwatch(palette: .lightGray, title: "LightGray")
            PaletteSwatch(palette: .white, title: "White")
            PaletteSwatch(palette: .empty, title: "Empty")
            PaletteSwatch(palette: .amount, title: "Amount")
            PaletteSwatch(palette: .listStyleColor, title: "ListStyle")
        }
    }
    .listStyle(.plain)
    .padding()
}
