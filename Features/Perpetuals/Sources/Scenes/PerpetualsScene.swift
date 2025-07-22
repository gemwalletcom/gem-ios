import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualsScene: View {
    
    @State private var model: PerpetualsSceneViewModel
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        self._model = State(initialValue: PerpetualsSceneViewModel(
            wallet: wallet,
            perpetualService: perpetualService
        ))
    }
    
    public var body: some View {
        List {
            if !model.positionViewModels.isEmpty {
                Section {
                    ForEach(model.positionViewModels) { viewModel in
                        ListAssetItemView(model: viewModel)
                    }
                    .listRowInsets(.assetListRowInsets)
                } header: {
                    HStack {
                        Text("Positions")
                        Spacer()
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                }
            }
            
            Section {
                if model.perpetuals.isEmpty {
                    Text("No markets")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(model.perpetuals, id: \.id) {
                        ListAssetItemView(
                            model: PerpetualMarketItemViewModel(perpetual: $0)
                        )
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            } header: {
                Text("Markets")
            }
        }
        .navigationTitle("Perpetuals")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            model.fetch()
            
            // Update every 5 seconds
            for await _ in Timer.publish(every: 5, on: .main, in: .common).autoconnect().values {
                await model.updatePositions()
                await model.updateMarkets()
            }
        }
        .observeQuery(request: $model.positionsRequest, value: $model.positions)
        .observeQuery(request: $model.perpetualsRequest, value: $model.perpetuals)
        .refreshable {
            await model.updatePositions()
        }
    }
}
