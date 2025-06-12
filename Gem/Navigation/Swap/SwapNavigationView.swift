// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import ChainService
import Components
import InfoSheet
import Swap
import Assets
import Transfer

struct SwapNavigationView: View {
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.scanService) private var scanService


    @State private var model: SwapSceneViewModel
    @Binding private var navigationPath: NavigationPath

    private let onComplete: VoidAction

    init(
        model: SwapSceneViewModel,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.model = model
        self.onComplete = onComplete
        _navigationPath = navigationPath
    }

    var body: some View {
        SwapScene(model: model)
            .onChange(of: model.swapState.swapTransferData.value) { oldValue, newValue in
                guard let newValue else { return }
                navigationPath.append(newValue)
            }
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: model.wallet,
                        data: data,
                        keystore: model.keystore,
                        chainService: ChainServiceFactory(nodeProvider: nodeService)
                            .service(for: data.chain),
                        scanService: scanService,
                        walletsService: model.walletsService,
                        onComplete: {
                            onSwapComplete(type: data.type)
                        }
                    )
                )
            }
            .sheet(item: $model.isPresentedInfoSheet) {
                switch $0 {
                case let .info(type):
                    InfoSheetScene(model: InfoSheetViewModel(type: type))
                case let .selectAsset(type):
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: .swap(type),
                            assetsService: assetsService,
                            walletsService: model.walletsService,
                            priceAlertService: priceAlertService,
                            selectAssetAction: model.onFinishAssetSelection
                        ),
                        isPresentingSelectType: .constant(.swap(type))
                    )
                case let .swapProvider(asset):
                    SelectableListNavigationStack(
                        model: model.swapProvidersViewModel(asset: asset),
                        onFinishSelection: model.onFinishSwapProvderSelection,
                        listContent: { SimpleListItemView(model: $0) }
                    )
                }
            }
    }
}

// MARK: - Actions

extension SwapNavigationView {
    private func onSwapComplete(type: TransferDataType) {
        switch type {
        case .swap, .tokenApprove:
            onComplete?()
        default: break
        }
    }
}
