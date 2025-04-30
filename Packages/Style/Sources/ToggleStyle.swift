// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct AppToggleStyle: ToggleStyle {
    
    var tintColor: Color
    
    public init(
        tintColor: Color = Colors.green
    ) {
        self.tintColor = tintColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .tint(Colors.blue)
    }
}

public struct CheckboxStyle: ToggleStyle {
    public enum CheckboxPosition {
        case left
        case right
    }
    
    let position: CheckboxPosition
    
    public init(position: CheckboxPosition) {
        self.position = position
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            if position == .left {
                checkboxView(configuration: configuration)
                Spacer()
            }

            configuration.label
            
            if position == .right {
                Spacer()
                checkboxView(configuration: configuration)
            }
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
    
    private func checkboxView(configuration: Configuration) -> some View {
        Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
            .resizable()
            .frame(width: .image.small, height: .image.small)
            .foregroundColor(configuration.isOn ? Colors.blue : Colors.gray)
    }
}
