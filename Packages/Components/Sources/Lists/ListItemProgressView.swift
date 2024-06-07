// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ListItemProgressView: View {

    public let size: ControlSize
    public let tint: Color

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
