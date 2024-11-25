// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Primitives
import Style
import Components
import GRDB
import GRDBQuery
import Store

struct ChartScene: View {
    
    @StateObject var model: ChartsViewModel
    
    @Query<PriceRequest>
    var priceData: PriceData

    init(
        model: ChartsViewModel
    ) {
        _model = StateObject(wrappedValue: model)
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
            
            let priceDataModel = AssetDetailsInfoViewModel(priceData: priceData)
            
            if priceDataModel.showMarketValues {
                Section {
                    ForEach(priceDataModel.marketValues, id: \.title) {
                        ListItemView(title: $0.title, subtitle: $0.subtitle)
                    }
                }
            }
            if priceDataModel.showLinksSection {
                Section(priceDataModel.linksSectionText) {
                    ForEach(priceDataModel.links) { link in
                        NavigationOpenLink(
                            url: link.url,
                            with: ListItemView(title: link.type.name, subtitle: link.host, image: link.type.image)
                        )
                    }
                }
            }
        }
        .refreshable {
            await fetch()
        }
        .taskOnce {
            Task { await fetch() }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
    
    func fetch() async {
        await model.updateCharts()
    }
}
