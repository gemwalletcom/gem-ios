// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

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

// MARK: - ButtonStyle Static

extension ButtonStyle where Self == ClearButtonStyle {
    public static var clear: ClearButtonStyle { ClearButtonStyle(foregroundStyle: Colors.black, foregroundStylePressed: Colors.gray) }
    public static var clearBlue: ClearButtonStyle { ClearButtonStyle(foregroundStyle: Colors.blue, foregroundStylePressed: Colors.blueDark) }
}

// MARK: – Previews

#Preview {
    List {
        Section("ClearButtonStyle presets") {
            Button("Clear")      { }
                .buttonStyle(.clear)

            Button("Clear Blue") { }
                .buttonStyle(.clearBlue)
        }
    }
    .padding()
}
