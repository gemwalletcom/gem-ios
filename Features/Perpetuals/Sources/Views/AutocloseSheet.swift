// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents

public struct AutocloseSheet: View {
    private let openData: AutocloseOpenData
    private let onComplete: AutocloseCompletion

    public init(openData: AutocloseOpenData, onComplete: @escaping AutocloseCompletion) {
        self.openData = openData
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            AutocloseScene(model: AutocloseSceneViewModel(type: .open(openData, onComplete: onComplete)))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarDismissItem(title: .cancel, placement: .topBarLeading) }
        }
    }
}
