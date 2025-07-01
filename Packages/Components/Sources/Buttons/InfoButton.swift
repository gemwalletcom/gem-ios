// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct InfoButton: View {
    
    let action: (() -> Void)
    
    public init(action: @escaping (() -> Void)) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Images.System.info
                .foregroundStyle(Colors.gray)
                .frame(width: .list.image, height: .list.image)
        }
        .buttonStyle(.plain)
    }
}
