// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Primitives

struct SwapChangeView: View {
    @Binding private var fromId: AssetId?
    @Binding private var toId: AssetId?
    var isLoading: Bool

    init(
        fromId: Binding<AssetId?> = .constant(.none),
        toId: Binding<AssetId?> = .constant(.none),
        isLoading: Bool = false
    ) {
        _fromId = fromId
        _toId = toId
        self.isLoading = isLoading
    }

    var body: some View {
        if isLoading {
            LoadingView(tint: Colors.gray)
                .frame(size: .large)
        } else {
            Button {
                swap(&fromId, &toId)
            } label: {
                Images.System.arrowSwap
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(size: .large)
                    .foregroundStyle(Colors.gray)
            }
        }
    }
}
