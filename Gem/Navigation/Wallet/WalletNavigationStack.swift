// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import WalletTab

struct WalletNavigationStack: View {
    @Environment(\.navigationState) private var navigationState

    @State private var model: WalletSceneViewModel

    init(model: WalletSceneViewModel) {
        _model = State(initialValue: model)
    }

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.wallet },
            set: { navigationState.wallet = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            WalletScene(model: model)
                .onChange(of: model.currentWallet, model.onChangeWallet)
                .observeQuery(
                    request: $model.assetsRequest,
                    value: $model.assets
                )
                .observeQuery(
                    request: $model.bannersRequest,
                    value: $model.banners
                )
                .observeQuery(
                    request: $model.totalFiatRequest,
                    value: $model.totalFiatValue
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        WalletBarView(
                            model: model.walletBarModel,
                            action: model.onSelectWalletBar
                        )
                        .liquidGlass()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: model.onSelectManage) {
                            model.manageImage
                        }
                    }
                }
                .walletNavigationFlow(
                    wallet: model.wallet,
                    isPresentingSelectedAssetInput: model.isPresentingSelectedAssetInput,
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
                .sheet(isPresented: $model.isPresentingWallets) {
                    WalletsNavigationStack(isPresentingWallets: $model.isPresentingWallets)
                }
        }
    }
}
