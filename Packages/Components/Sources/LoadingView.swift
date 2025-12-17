// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct LoadingView: View {
    public let size: ControlSize
    public let tint: Color

    public init(size: ControlSize = .regular, tint: Color = Colors.gray) {
        self.size = size
        self.tint = tint
    }

    public var body: some View {
        ProgressView()
            .controlSize(size)
            .progressViewStyle(.circular)
            .tint(tint)
    }
}

public struct CenterLoadingView: View {
    
    public init() {}
    
    public var body: some View {
        HStack {
            Spacer()
            LoadingView()
            Spacer()
        }
    }
}
