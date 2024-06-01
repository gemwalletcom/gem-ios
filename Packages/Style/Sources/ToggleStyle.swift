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
