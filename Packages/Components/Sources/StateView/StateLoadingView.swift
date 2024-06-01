// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateLoadingView: View {

    public init() {}
    
    public var body: some View {
        ProgressView()
            .controlSize(.large)
            .progressViewStyle(.circular)
            .tint(Colors.gray)
    }
}
