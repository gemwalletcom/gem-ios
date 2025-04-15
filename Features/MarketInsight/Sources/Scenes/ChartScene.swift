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
    private let fetchTimer = Timer.publish(every: 60, tolerance: 1, on: .main, in: .common).autoconnect()
    @State private var model: ChartsViewModel

    @Query<PriceRequest>
    private var priceData: PriceData

    public init(model: ChartsViewModel) {
        _model = State(initialValue: model)
        _priceData = Query(constant: model.priceRequest)
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

                    HStack(alignment: .center, spacing: .medium) {
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
                    .padding(.bottom, .medium)
                }
            }
            .cleanListRow()

            let priceDataModel = AssetDetailsInfoViewModel(priceData: priceData)
            
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
    }
}
