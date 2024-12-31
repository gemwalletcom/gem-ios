// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

public struct FiatConnectNavigationView: View {
    private let assetAddress: AssetAddress
    private let walletId: String
    private let type: FiatTransactionType

    @Binding private var navigationPath: NavigationPath

    public init(
        assetAddress: AssetAddress,
        walletId: String,
        type: FiatTransactionType,
        navigationPath: Binding<NavigationPath>
    ) {
        self.assetAddress = assetAddress
        self.walletId = walletId
        self.type = type
        _navigationPath = navigationPath
    }

    public var body: some View {
        let model = FiatSceneViewModel(
            assetAddress: assetAddress,
            walletId: walletId,
            type: type
        )
        FiatScene(
            model: model,
            onOpenFiatProvider: { model in
                navigationPath.append(model)
            }
        )
        .navigationDestination(for: FiatProvidersViewModel.self) {
            FiatProvidersScene(
                model: $0,
                onSelectQuote: {
                    model.onSelectQuote($0)
                    navigationPath.removeLast()
                }
            )
        }
    }
}
