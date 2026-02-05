// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import InfoSheet
import Swap
import Assets
import AssetsService
import Style

struct SwapNavigationView: View {
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.activityService) private var activityService
    @Environment(\.assetSearchService) private var assetSearchService

    @State private var model: SwapSceneViewModel

    init(model: SwapSceneViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        SwapScene(model: model)
            .sheet(item: $model.isPresentingInfoSheet) {
                switch $0 {
                case let .info(type):
                    InfoSheetScene(type: type)
                case let .selectAsset(type):
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: .swap(type),
                            searchService: assetSearchService,
                            walletsService: model.walletsService,
                            priceAlertService: priceAlertService,
                            activityService: activityService,
                            selectAssetAction: model.onFinishAssetSelection
                        ),
                        isPresentingSelectType: .constant(.swap(type))
                    )
                case .swapDetails:
                    if let model = model.swapDetailsViewModel {
                        NavigationStack {
                            SwapDetailsView(model: Bindable(model))
                                .presentationDetentsForCurrentDeviceSize(expandable: true)
                                .presentationBackground(Colors.grayBackground)
                        }
                    }
                }
            }
    }
}
