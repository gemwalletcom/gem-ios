// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct TextStyle {
    public let font: Font
    public let color: Color
    public let background: Color
    
    public init(
        font: Font,
        color: Color,
        background: Color = Colors.black
    ) {
        self.font = font
        self.color = color
        self.background = background
    }
}

// MARK: - 

extension TextStyle {
    // if you extend this and want to check previews in packages, please also
    // add same apple color value in /Previews/TextStyle+Preview
    public static let title = TextStyle(font: .title, color: Colors.black)
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
            .textStyle(TextStyle.Preview.title)
        Text("Headline")
            .textStyle(TextStyle.Preview.headline)
        Text("Subheadline")
            .textStyle(TextStyle.Preview.subheadline)
        Text("Body text that provides additional information.")
            .textStyle(TextStyle.Preview.body)
        Text("Callout")
            .textStyle(TextStyle.Preview.callout)
        Text("Footnote")
            .textStyle(TextStyle.Preview.footnote)
        Text("Caption")
            .textStyle(TextStyle.Preview.caption)
        Text("Large Title")
            .textStyle(TextStyle.Preview.largeTitle)
        Text("Bold Title")
            .textStyle(TextStyle.Preview.boldTitle)
        Text("Highlighted Text")
            .textStyle(TextStyle.Preview.highlighted)
    }
    .padding()
}
