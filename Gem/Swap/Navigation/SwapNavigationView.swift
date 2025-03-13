// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import SwapService
import ChainService
import Components
import Localization
import InfoSheet

struct SwapNavigationView: View {
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.priceAlertService) private var priceAlertService

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
                        keystore: model.keystore,
                        data: data,
                        service: ChainServiceFactory(nodeProvider: nodeService)
                            .service(for: data.chain),
                        walletsService: model.walletsService,
                        onComplete: {
                            onSwapComplete(type: data.type)
                        }
                    )
                )
            }
            .sheet(item: $model.presentedSheet) {
                switch $0 {
                case let .info(type):
                    InfoSheetScene(model: InfoSheetViewModel(type: type))
                case let .selectAsset(type):
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            keystore: model.keystore,
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
