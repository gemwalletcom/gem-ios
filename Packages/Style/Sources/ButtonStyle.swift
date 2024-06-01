// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct BlueButton: ButtonStyle {
    
    @Environment(\.isEnabled) var isEnabled
    
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    
    public init(
        paddingHorizontal: CGFloat = 16,
        paddingVertical: CGFloat = 16
    ) {
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
    }
    
    public func backgroundColor(isPressed: Bool ) -> Color {
        if isPressed {
            return Colors.blueDark
        } 
//        else if !isEnabled {
//            return Colors.gray
//        }
        return Colors.blue
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
            .foregroundColor(Colors.whiteSolid)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .cornerRadius(12)
            .fontWeight(.semibold)
    }
}

public struct ClearButton: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(configuration.isPressed ? Colors.gray : Colors.black)
    }
}

public struct ColorButton: ButtonStyle {
    
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let foregroundColor: Color
    let foregroundColorPressed: Color
    let backgroundColor: Color
    let backgroundColorPressed: Color
    
    public init(
        paddingHorizontal: CGFloat,
        paddingVertical: CGFloat,
        foregroundColor: Color,
        foregroundColorPressed: Color,
        backgroundColor: Color,
        backgroundColorPressed: Color
    ) {
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.foregroundColor = foregroundColor
        self.foregroundColorPressed = foregroundColorPressed
        self.backgroundColor = backgroundColor
        self.backgroundColorPressed = backgroundColorPressed
    }
    
    public static func gray(
        paddingHorizontal: CGFloat = 16,
        paddingVertical: CGFloat = 16
    ) -> ColorButton {
        return Self(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundColor: Colors.whiteSolid,
            foregroundColorPressed: Colors.whiteSolid,
            backgroundColor: Colors.grayLight,
            backgroundColorPressed: Colors.gray
        )
    }
    
    public static func blue(
        paddingHorizontal: CGFloat = 16,
        paddingVertical: CGFloat = 16
    ) -> ColorButton {
        return Self(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundColor: Colors.whiteSolid,
            foregroundColorPressed: Colors.whiteSolid,
            backgroundColor: Colors.blue,
            backgroundColorPressed: Colors.gray
        )
    }
    
    public static func lightGray(
        paddingHorizontal: CGFloat = 16,
        paddingVertical: CGFloat = 16
    ) -> ColorButton {
        return Self(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundColor: Colors.gray,
            foregroundColorPressed: Colors.whiteSolid,
            backgroundColor: Colors.grayVeryLight,
            backgroundColorPressed: Colors.grayLight
        )
    }
    
    public static func white(
        paddingHorizontal: CGFloat = 16,
        paddingVertical: CGFloat = 16
    ) -> ColorButton {
        return Self(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            foregroundColor: Colors.gray,
            foregroundColorPressed: Colors.whiteSolid,
            backgroundColor: Colors.white,
            backgroundColorPressed: Colors.grayVeryLight
        )
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, paddingVertical)
            .padding(.horizontal, paddingHorizontal)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? foregroundColorPressed : foregroundColor)
            .background(configuration.isPressed ? backgroundColorPressed : backgroundColor)
            .cornerRadius(12)
            .fontWeight(.semibold)
    }
}
