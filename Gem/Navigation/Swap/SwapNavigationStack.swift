// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Swap
import SwapService
import Primitives

struct SwapNavigationStack: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService

    @State private var navigationPath: NavigationPath = NavigationPath()

    private let input: SwapInput
    private let onComplete: VoidAction

    init(
        input: SwapInput,
        onComplete: VoidAction
    ) {
        self.input = input
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SwapNavigationView(
                model: SwapSceneViewModel(
                    input: input,
                    walletsService: walletsService,
                    swapQuotesProvider: SwapQuotesProvider(swapService: SwapService(nodeProvider: nodeService)),
                    onSwap: {
                        navigationPath.append($0)
                    }
                ),
                onComplete: onComplete
            )
            .toolbarDismissItem(title: .done, placement: .topBarLeading)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
