// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateEmptyView: View {

    let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        VStack {
            Text(message)
        }
        .tint(Colors.black)
    }
}
