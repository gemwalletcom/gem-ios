// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Primitives
import Style
import Components
import GRDB
import GRDBQuery
import Store
import PrimitivesComponents
import Localization

public struct ChartScene: View {
    @State private var model: ChartSceneViewModel

    public init(model: ChartSceneViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        List {
            Section { } header: {
                ChartStateView(
                    state: model.state,
                    selectedPeriod: $model.selectedPeriod
                )
            }
            .cleanListRow()
            
            if model.showPriceAlerts, let asset = model.priceData?.asset {
                NavigationLink(
                    value: Scenes.AssetPriceAlert(asset: asset),
                    label: {
                        ListItemView(
                            title: model.priceAlertsViewModel.priceAlertsTitle,
                            subtitle: model.priceAlertsViewModel.priceAlertCount
                        )
                    }
                )
            } else if model.isPriceAvailable {
                NavigationCustomLink(
                    with: ListItemView(
                        title: model.priceAlertsViewModel.setPriceAlertTitle
                    )
                ) {
                    model.onSelectSetPriceAlerts()
                }
            }

            if let priceDataModel = model.priceDataModel {
                if priceDataModel.showMarketValues {
                    Section {
                        ForEach(priceDataModel.marketValues, id: \.title) { link in
                            if let url = link.url {
                                SafariNavigationLink(url: url) {
                                    ListItemView(title: link.title, subtitle: link.subtitle)
                                }
                                .contextMenu(
                                    link.value.map { [.copy(value: $0)] } ?? []
                                )
                            } else {
                                ListItemView(
                                    title: link.title,
                                    titleTag: link.titleTag,
                                    titleTagStyle: link.titleTagStyle ?? .body,
                                    subtitle: link.subtitle
                                )
                            }
                        }
                        if model.hasMarketData {
                            NavigationCustomLink(
                                with: ListItemView(title: Localized.Wallet.more)
                            ) {
                                model.onSelectPriceDetails()
                            }
                        }
                    }
                }
                
                if priceDataModel.showLinks {
                    Section(Localized.Social.links) {
                        SocialLinksView(model: priceDataModel.linksViewModel)
                    }
                }
            }
        }
        .observeQuery(request: $model.priceRequest, value: $model.priceData)
        .refreshable {
            await model.fetch()
        }
        .task {
            await model.fetch()
        }
        .onTimer(every: .minute1) {
            await model.fetch()
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .sheet(item: $model.isPresentingMarkets) { priceData in
            NavigationStack {
                AssetPriceDetailsView(
                    model: AssetPriceDetailsViewModel(priceData: priceData)
                )
            }
            .presentationBackground(Colors.grayBackground)
        }
    }
}
