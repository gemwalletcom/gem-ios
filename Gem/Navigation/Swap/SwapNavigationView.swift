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
import ExplorerService
import Signer

struct SwapNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService
    @Environment(\.transactionService) private var transactionService

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
                        confirmService: ConfirmServiceFactory.create(
                            keystore: keystore,
                            nodeService: nodeService,
                            walletsService: model.walletsService,
                            scanService: scanService,
                            swapService: swapService,
                            balanceService: balanceService,
                            priceService: priceService,
                            transactionService: transactionService,
                            chain: data.chain
                        ),
                        onComplete: {
                            onSwapComplete(type: data.type)
                        }
                    )
                )
            }
            .sheet(item: $model.isPresentingInfoSheet) {
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
