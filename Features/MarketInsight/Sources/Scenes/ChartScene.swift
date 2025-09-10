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
import PriceAlerts

public struct ChartScene: View {
    private let fetchTimer = Timer.publish(every: 60, tolerance: 1, on: .main, in: .common).autoconnect()
    @State private var model: ChartsViewModel

    public init(model: ChartsViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        List {
            Section { } header: {
                VStack {
                    VStack {
                        switch model.state {
                        case .noData:
                            StateEmptyView(title: model.emptyTitle)
                        case .loading:
                            LoadingView()
                        case .data(let model):
                            ChartView(model: model)
                        case .error(let error):
                            StateEmptyView(
                                title: model.errorTitle,
                                description: error.localizedDescription,
                                image: Images.ErrorConent.error
                            )
                        }
                    }
                    .frame(height: 320)

                    PeriodSelectorView(selectedPeriod: $model.currentPeriod)
                }
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
            } else {
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
        .onReceive(fetchTimer) { time in
            Task {
                await model.fetch()
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .toast(message: $model.isPresentingToastMessage)
        .sheet(isPresented: $model.isPresentingSetPriceAlert) {
            SetPriceAlertNavigationStack(
                model: SetPriceAlertViewModel(
                    walletId: model.walletId,
                    assetId: model.assetModel.asset.id,
                    priceAlertService: model.priceAlertService
                ) { model.onSetPriceAlertComplete(message: $0) }
            )
        }
    }
}
