// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import ChainService
import Components
import InfoSheet
import Swap
import Assets
import Transfer
import SwapService

struct SwapNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService

    @State private var model: SwapSceneViewModel

    private let onComplete: VoidAction

    init(
        model: SwapSceneViewModel,
        onComplete: VoidAction
    ) {
        _model = State(initialValue: model)
        self.onComplete = onComplete
    }

    var body: some View {
        SwapScene(model: model)
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: model.wallet,
                        data: data,
                        keystore: keystore,
                        chainService: ChainServiceFactory(nodeProvider: nodeService)
                            .service(for: data.chain),
                        scanService: scanService,
                        swapService: swapService,
                        walletsService: model.walletsService,
                        swapDataProvider: SwapQuoteDataProvider(
                            keystore: keystore,
                            swapService: swapService
                        ),
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
                case .swapDetails:
                    if let model = model.swapDetailsViewModel {
                        NavigationStack {
                            SwapDetailsView(model: Bindable(model))
                                .presentationDetentsForCurrentDeviceSize(expandable: true)
                        }
                    }
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
