// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct LoadingView: View {
    public let size: ControlSize
    public let tint: Color

    public init(tint: Color = Colors.gray) {
        self.init(size: .regular, tint: tint)
    }

    public init(size: ControlSize, tint: Color) {
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
