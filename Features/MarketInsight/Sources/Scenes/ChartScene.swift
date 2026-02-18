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
import InfoSheet

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
                marketSection(priceDataModel.marketValues)
                marketSection(priceDataModel.supplyValues)
                marketSection(priceDataModel.allTimeValues)

                if priceDataModel.showLinks {
                    Section(Localized.Social.links) {
                        SocialLinksView(model: priceDataModel.linksViewModel)
                    }
                }
            }
        }
        .observeQuery(request: $model.priceRequest, value: $model.priceData)
        .refreshableTimer(every: .minutes(1)) {
            await model.fetch()
        }
        .task {
            await model.fetch()
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(type: $0)
        }
    }

    private func marketSection(_ items: [MarketValueViewModel]) -> some View {
        Section {
            ForEach(items, id: \.title) { item in
                if let url = item.url {
                    SafariNavigationLink(url: url) {
                        ListItemView(title: item.title, subtitle: item.subtitle)
                    }
                    .contextMenu(
                        item.value.map { [.copy(value: $0)] } ?? []
                    )
                } else {
                    ListItemView(
                        title: item.title,
                        titleTag: item.titleTag,
                        titleTagStyle: item.titleTagStyle ?? .body,
                        titleExtra: item.titleExtra,
                        subtitle: item.subtitle,
                        subtitleExtra: item.subtitleExtra,
                        subtitleStyleExtra: item.subtitleExtraStyle ?? .calloutSecondary,
                        infoAction: item.infoSheetType.map { type in { model.isPresentingInfoSheet = type } }
                    )
                }
            }
        }
    }
}
