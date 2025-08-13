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
                                .Perpetual(perpetualData: PerpetualData(
                                    perpetual: positionData.perpetual,
                                    asset: positionData.asset,
                                    metadata: PerpetualMetadata(isPinned: false)
                                ))
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
            
            if !model.sections.pinned.isEmpty {
                Section {
                    PerpetualSectionView(
                        perpetuals: model.sections.pinned,
                        onPin: model.onPinPerpetual
                    )
                } header: {
                    HStack {
                        model.pinImage
                        Text(model.pinnedSectionTitle)
                    }
                }
            }
            
            Section {
                PerpetualSectionView(
                    perpetuals: model.sections.markets,
                    onPin: model.onPinPerpetual,
                    emptyText: model.noMarketsText
                )
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
        }
        .onReceive(model.timer) { _ in
            Task {
                await model.fetch()
            }
        }
        .refreshable {
            await model.fetch()
        }
    }
}
