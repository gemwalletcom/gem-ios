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
        backgroundDisabled: Colors.blueDarkFaded
    )

    static let blue = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blue,
        backgroundPressed: Colors.blueDark,
        backgroundDisabled: Colors.blueFaded
    )

    static let blueGrayPressed = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blue,
        backgroundPressed: Colors.gray,
        backgroundDisabled: Colors.blueFaded
    )

    static let gray = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.grayLight,
        backgroundPressed: Colors.gray,
        backgroundDisabled: Colors.grayLightFaded
    )

    static let lightGray = ButtonStylePalette(
        foreground: Colors.gray,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.grayVeryLight,
        backgroundPressed: Colors.grayLightFaded,
        backgroundDisabled: Colors.grayVeryLightFaded
    )

    static let white = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.white,
        backgroundPressed: Colors.grayVeryLight,
        backgroundDisabled: Colors.whiteFaded
    )

    static let empty = ButtonStylePalette(
        foreground: Colors.black,
        foregroundPressed: Colors.blackFaded,
        background: Colors.Empty.buttonsBackground,
        backgroundPressed: Colors.Empty.buttonsBackground,
        backgroundDisabled: Colors.Empty.buttonsBackground
    )

    static let amount = ButtonStylePalette(
        foreground: Colors.black,
        foregroundPressed: Colors.blackFaded,
        background: Colors.grayVeryLight,
        backgroundPressed: Colors.grayVeryLightFaded,
        backgroundDisabled: Colors.grayVeryLightFaded
    )

    static let listStyleColor = ButtonStylePalette(
        foreground: Colors.gray,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.listStyleColor,
        backgroundPressed: Colors.grayVeryLight,
        backgroundDisabled: Colors.grayFaded
    )
    
    static let red = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.red,
        backgroundPressed: Colors.redFaded,
        backgroundDisabled: Colors.redFadedLight
    )
    
    static let green = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.green,
        backgroundPressed: Colors.greenFaded,
        backgroundDisabled: Colors.greenFadedLight
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
