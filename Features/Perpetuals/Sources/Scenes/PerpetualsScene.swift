// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService
import PrimitivesComponents
import Preferences

public struct PerpetualsScene: View {
    
    let model: PerpetualsSceneViewModel
    
    public init(model: PerpetualsSceneViewModel) {
        self.model = model
    }
    
    public var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(
                    model: model.headerViewModel,
                    isHideBalanceEnalbed: .constant(model.preferences.isHideBalanceEnabled),
                    onHeaderAction: model.onHeaderAction,
                    onInfoAction: { }
                )
                .padding(.top, Spacing.small)
            }
            .cleanListRow()
            
            if !model.positions.isEmpty {
                Section {
                    ForEach(model.positions) { positionData in
                        NavigationLink(
                            value: Scenes
                                .Perpetual(perpetualData: PerpetualData(perpetual: positionData.perpetual, asset: positionData.asset))
                        ) {
                            ListAssetItemView(model: PerpetualPositionItemViewModel(
                                model: PerpetualPositionViewModel(
                                    data: positionData
                                )
                            ))
                        }
                        .listRowInsets(.assetListRowInsets)
                    }
                } header: {
                    Text(model.positionsSectionTitle)
                }
            }
            
            Section {
                if model.perpetuals.isEmpty {
                    Text(model.noMarketsText)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(model.perpetuals) { perpetualData in
                        NavigationLink(value: Scenes.Perpetual(perpetualData: perpetualData)) {
                            ListAssetItemView(
                                model: PerpetualItemViewModel(
                                    model: PerpetualViewModel(
                                        perpetual: perpetualData.perpetual,
                                        currencyStyle: .abbreviated
                                    )
                                )
                            )
                        }
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            } header: {
                Text(model.marketsSectionTitle)
            }
        }
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .taskOnce {
            Task {
                await model.fetch()
            }
            Task {
                await model.updateMarkets()
            }
        }
        .onReceive(Timer.publish(every: 5, tolerance: 1, on: .main, in: .common).autoconnect()) { _ in
            Task {
                await model.fetch()
            }
        }
        .refreshable {
            await model.fetch()
        }
    }
}
