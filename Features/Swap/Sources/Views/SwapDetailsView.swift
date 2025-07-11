// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import PrimitivesComponents
import InfoSheet
import Localization

public struct SwapDetailsView: View {
    
    private let model: SwapDetailsViewModel
    
    @State private var isPresentingInfoSheet: InfoSheetType?
    
    public init(model: SwapDetailsViewModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack {
            switch model.state {
            case .data: listView
            case .error(let error): ListItemErrorView(error: error)
            case .loading: LoadingView()
            case .noData: EmptyView()
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .toolbarDismissItem(title: .done, placement: .topBarLeading)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
    }

    private var listView: some View {
        List {
            Section {
                ForEach(model.providers) { item in
                    let view = SimpleListItemView(model: item)
                    if model.allowSelectProvider {
                        NavigationCustomLink(
                            with: view
                        ) {
                            model.onFinishSwapProviderSelection(item: item)
                        }
                    } else {
                        view
                    }
                }
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
                    infoAction: { isPresentingInfoSheet = .priceImpact }
                )
            }
        }
    }
}


