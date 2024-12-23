// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Primitives
import Style
import Components
import GRDB
import GRDBQuery
import Store
import MarketInsight

struct ChartScene: View {
    @Environment(\.openURL) private var openURL

    @State private var model: ChartSceneViewModel

    @Query<PriceRequest>
    private var priceData: PriceData

    init(
        model: ChartSceneViewModel
    ) {
        _model = State(initialValue: model)
        _priceData = Query(constant: model.priceRequest)
    }

    var body: some View {
        List {
            Section { } header: {
                VStack {
                    VStack {
                        switch model.state {
                        case .noData:
                            StateEmptyView(title: model.emptyTitle)
                        case .loading:
                            LoadingView()
                        case .loaded(let model):
                            ChartView(model: model)
                        case .error(let error):
                            StateEmptyView(
                                title: model.errorTitle,
                                description: error.localizedDescription,
                                image: Images.System.errorOccurred
                            )
                        }
                    }
                    .frame(height: 320)

                    HStack(alignment: .center, spacing: Spacing.medium) {
                        ForEach(model.periods) { period in
                            Button {
                                model.currentPeriod = period.period
                            } label: {
                                Text(period.title)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(6)
                                    .background(model.currentPeriod == period.period ? Colors.white : .clear)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.bottom, Spacing.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())

            let priceDataModel = AssetDetailsInfoViewModel(
                priceData: priceData,
                explorerStorage: model.explorerStorage,
                currencyFormatter: .currency()
            )

            if priceDataModel.showMarketValues {
                Section {
                    ForEach(priceDataModel.marketValues, id: \.title) { link in
                        if let url = link.url {
                            NavigationCustomLink(with: ListItemView(title: link.title, subtitle: link.subtitle)) {
                                openURL(url)
                            }
                            .contextMenu {
                                if let value = link.value {
                                    ContextMenuCopy(value: value)
                                }
                            }
                        } else {
                            ListItemView(title: link.title, subtitle: link.subtitle)
                        }
                    }
                }
            }
            if priceDataModel.showLinksSection {
                Section(priceDataModel.linksSectionText) {
                    ForEach(priceDataModel.links) {
                        NavigationOpenLink(
                            url: $0.url,
                            with: ListItemView(title: $0.title, subtitle: $0.subtitle, image: $0.image)
                        )
                    }
                }
            }
        }
        .refreshable {
            await model.fetch()
        }
        .task {
            await model.fetch()
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}
