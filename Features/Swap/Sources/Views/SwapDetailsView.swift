// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import PrimitivesComponents
import InfoSheet
import Localization
import Primitives

public struct SwapDetailsView: View {
    @Bindable private var model: SwapDetailsViewModel
    public init(model: Bindable<SwapDetailsViewModel>) {
        _model = model
    }

    public var body: some View {
        VStack {
            switch model.state {
            case .data: listView
            case .error(let error): List { ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error) }
            case .loading: LoadingView()
            case .noData: List { ListItemErrorView(errorTitle: nil, error: AnyError(Localized.Errors.errorOccured)) }
            }
        }
        .toolbarDismissItem(type: .close, placement: .topBarLeading)
        .navigationTitle(Localized.Common.details)
        .navigationBarTitleDisplayMode(.inline)
        .listSectionSpacing(.compact)
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(type: $0)
        }
        .sheet(isPresented: $model.isPresentingSwapProviderSelectionSheet) {
            SelectableListNavigationStack(
                model: model.swapProvidersViewModel,
                onFinishSelection: model.onFinishSwapProviderSelection,
                listContent: { SimpleListItemView(model: $0) }
            )
        }
    }

    private var listView: some View {
        List {
            Section {
                let view = SimpleListItemView(model: model.selectedProviderItem)
                if model.allowSelectProvider {
                    NavigationCustomLink(
                        with: view
                    ) {
                        model.onSelectProvidersSelection()
                    }
                } else {
                    view
                }
            } header: {
                Text(Localized.Common.provider)
                    .listRowInsets(.horizontalMediumInsets)
            }
            
            Section {
                if let rateText = model.rateText {
                    ListItemRotateView(
                        title: model.rateTitle,
                        subtitle: rateText,
                        action: model.switchRateDirection
                    )
                }

                if let swapEstimation = model.swapEstimationText {
                    ListItemView(title: model.swapEstimationTitle, subtitle: swapEstimation)
                }
                
                PriceImpactView(
                    model: model.priceImpactModel,
                    infoAction: model.onSelectPriceImpactInfoSheet
                )
                
                ListItemView(
                    title: model.minReceiveTitle,
                    subtitle: model.minReceiveText
                )

                ListItemView(
                    title: model.slippageTitle,
                    subtitle: model.slippageText,
                    infoAction: model.onSelectSlippageInfoSheet
                )
            }
        }
    }
}


