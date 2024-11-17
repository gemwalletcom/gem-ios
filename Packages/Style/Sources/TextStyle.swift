// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct TextStyle: Sendable {
    public let font: Font
    public let fontWeight: Font.Weight?
    public let color: Color
    public let background: Color
    
    public init(
        font: Font,
        color: Color,
        fontWeight: Font.Weight? = nil,
        background: Color = Colors.black
    ) {
        self.font = font
        self.color = color
        self.fontWeight = fontWeight
        self.background = background
    }

    public func weight(_ weight: Font.Weight) -> TextStyle {
        TextStyle(
            font: font,
            color: color,
            fontWeight: weight,
            background: background
        )
    }
}

// MARK: - TextStyle Static

extension TextStyle {
    public static let title = TextStyle(font: .title, color: Colors.black)
    public static let title2 = TextStyle(font: .title2, color: Colors.black)
    public static let title3 = TextStyle(font: .title3, color: Colors.black)
    public static let headline = TextStyle(font: .headline, color: Colors.black)
    public static let subheadline = TextStyle(font: .subheadline, color: Colors.secondaryText)
    public static let body = TextStyle(font: .body, color: Colors.black)
    public static let callout = TextStyle(font: .callout, color: Colors.black)
    public static let calloutSecondary = TextStyle(font: .callout, color: Colors.secondaryText)
    public static let footnote = TextStyle(font: .footnote, color: Colors.secondaryText)
    public static let caption = TextStyle(font: .caption, color: Colors.secondaryText)
    public static let largeTitle = TextStyle(font: .largeTitle, color: Colors.black)
    public static let boldTitle = TextStyle(font: .title.bold(), color: Colors.black)
    public static let highlighted = TextStyle(font: .headline, color: .white, background: Colors.blue)
}

// MARK: - Modifier

struct TextStyleModifier: ViewModifier {
    let style: TextStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .fontWeight(style.fontWeight)
            .foregroundStyle(style.color)
    }
}

// MARK: -

extension Text {
    public func textStyle(_ style: TextStyle) -> some View {
        self.modifier(TextStyleModifier(style: style))
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 16) {
        Text("Title")
            .textStyle(.title)
        Text("Headline")
            .textStyle(.headline)
        Text("Subheadline")
            .textStyle(.subheadline)
        Text("Body text that provides additional information.")
            .textStyle(.body)
        Text("Callout")
            .textStyle(.callout)
        Text("Footnote")
            .textStyle(.footnote)
        Text("Caption")
            .textStyle(.caption)
        Text("Large Title")
            .textStyle(.largeTitle)
        Text("Bold Title")
            .textStyle(.boldTitle)
        Text("Highlighted Text")
            .textStyle(.highlighted)
    }
    .padding()
}
