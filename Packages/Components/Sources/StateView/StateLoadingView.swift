// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

// TODO: - review where we using StateLoadingView and migrate to LoadingView if possible
@available(*, deprecated, message: "Use LoadingView for consistent list error styling across the app")
public struct StateLoadingView: View {

    public init() {}
    
    public var body: some View {
        ProgressView()
            .controlSize(.large)
            .progressViewStyle(.circular)
            .tint(Colors.gray)
    }
}
