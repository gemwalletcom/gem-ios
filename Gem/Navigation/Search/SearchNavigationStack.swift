// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import WalletTab
import InfoSheet
import Components
import Style

struct SearchNavigationStack: View {
    @Environment(\.navigationState) private var navigationState

    @State private var model: WalletSearchSceneViewModel
    @Binding private var isPresentingSelectedAssetInput: SelectedAssetInput?

    init(
        model: WalletSearchSceneViewModel,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        _model = State(initialValue: model)
        _isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.search },
            set: { navigationState.search = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            WalletSearchScene(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: model.currentWallet, model.onChangeWallet)
                .observeQuery(request: $model.request, value: $model.assets)
                .walletNavigationFlow(
                    wallet: model.wallet,
                    isPresentingSelectedAssetInput: $isPresentingSelectedAssetInput,
                    isPresentingInfoSheet: $model.isPresentingInfoSheet,
                    isPresentingSelectAssetType: $model.isPresentingSelectAssetType,
                    isPresentingTransferData: $model.isPresentingTransferData,
                    isPresentingPerpetualRecipientData: $model.isPresentingPerpetualRecipientData,
                    isPresentingSetPriceAlert: $model.isPresentingSetPriceAlert,
                    isPresentingUrl: $model.isPresentingUrl,
                    isPresentingToastMessage: $model.isPresentingToastMessage,
                    onTransferComplete: model.onTransferComplete,
                    onSetPriceAlertComplete: model.onSetPriceAlertComplete
                )
        }
    }
}
