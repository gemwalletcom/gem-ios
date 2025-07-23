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
            
            if !model.positionViewModels.isEmpty {
                Section {
                    ForEach(model.positionViewModels) { viewModel in
                        NavigationLink(value: Scenes.Perpetual(perpetual: viewModel.perpetual)) {
                            ListAssetItemView(model: viewModel)
                        }
                        .listRowInsets(.assetListRowInsets)
                    }
                } header: {
                    Text("Positions")
                }
            }
            
            Section {
                if model.perpetuals.isEmpty {
                    Text("No markets")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(model.perpetuals, id: \.id) { perpetual in
                        NavigationLink(value: Scenes.Perpetual(perpetual: perpetual)) {
                            ListAssetItemView(
                                model: PerpetualItemViewModel(perpetual: perpetual)
                            )
                        }
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            } header: {
                Text("Markets")
            }
        }
        .navigationTitle("Perpetuals")
        .navigationBarTitleDisplayMode(.inline)
        .taskOnce {
            Task {
                await model.fetch()
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
