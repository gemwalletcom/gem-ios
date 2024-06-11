// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateErrorView: View {

    let error: Error
    let message: String
    let action: (() -> Void)?
    
    public init(
        error: Error,
        message: String,
        action: (() -> Void)? = .none
    ) {
        self.error = error
        self.message = message
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text(error.localizedDescription)
            if action != nil {
                Button(message) {
                    action?()
                }
                .buttonStyle(.blue())
                .frame(width: 180)
            }
        }
    }
}
