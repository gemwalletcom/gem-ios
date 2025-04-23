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
    public init() {}

    public func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
                .resizable()
                .frame(width: .image.small, height: .image.small)
                .foregroundColor(configuration.isOn ? Colors.blue : Colors.gray)

            configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}
