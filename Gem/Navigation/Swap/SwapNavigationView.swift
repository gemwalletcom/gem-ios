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
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.assetsService) private var assetsService
    @Environment(\.priceAlertService) private var priceAlertService

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
                    model: viewModelFactory.confirmTransfer(
                        wallet: model.wallet,
                        data: data,
                        onComplete: {
                            onSwapComplete(type: data.type)
                        }
                    )
                )
            }
            .sheet(item: $model.isPresentingInfoSheet) {
                switch $0 {
                case let .info(type):
                    InfoSheetScene(type: type)
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
