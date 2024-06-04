// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Primitives
import Style
import Components
import GRDB
import GRDBQuery
import Store

struct ChartSelection {
    let period: ChartPeriod
    let title: String
}

struct ChartScene: View {
    
    @StateObject var model: ChartsViewModel
    
    @Query<AssetRequest>
    var assetData: AssetData
    
    init(
        model: ChartsViewModel
    ) {
        _model = StateObject(wrappedValue: model)
        _assetData = Query(constant: model.assetRequest, in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section { } header: {
                VStack {
                    VStack {
                        switch model.state {
                        case .noData:
                            StateEmptyView(message: Localized.Common.notAvailable)
                        case .loading:
                            StateLoadingView()
                        case .loaded(let model):
                            ChartView(model: model)
                        case .error(let error):
                            StateErrorView(error: error, message: Localized.Common.tryAgain)
                        }
                    }
                    .frame(height: 320)
                    
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(model.periods, id: \.period) { period in
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
                }
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            
            if let details = assetData.details {
                Section {
                    if let marketCap = details.market.marketCap {
                        ListItemView(
                            title: Localized.Asset.marketCap,
                            subtitle: CurrencyFormatter.currency().string(marketCap)
                        )
                    }
                    if let circulatingSupply = details.market.circulatingSupply {
                        ListItemView(
                            title: Localized.Asset.circulatingSupply,
                            subtitle: IntegerFormatter.standard.string(circulatingSupply)
                        )
                    }
                    if let totalSupply = details.market.totalSupply {
                        ListItemView(
                            title: Localized.Asset.totalSupply,
                            subtitle: IntegerFormatter.standard.string(totalSupply)
                        )
                    }
                }
                Section {
                    if let coingecko = details.details.links.coingecko, let url = URL(string: coingecko) {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transaction.viewOn("CoinGecko"))) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        .refreshable {
            NSLog("refresh chart asset \(model.assetModel.asset.name)")
            Task {
                await fetch()
            }
        }
        .taskOnce {
            Task { await model.updateAsset() }
            Task { await model.updateCharts() }
        }
        .navigationTitle(model.title)
    }
    
    func fetch() async {
        await model.updateCharts()
    }
}
