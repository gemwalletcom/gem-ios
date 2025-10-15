// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

public struct NetworkFeeSheet: View {
    private let model: NetworkFeeSceneViewModel

    public init(model: NetworkFeeSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            NetworkFeeScene(model: model)
                .presentationDetentsForCurrentDeviceSize(expandable: true)
        }
    }
}
