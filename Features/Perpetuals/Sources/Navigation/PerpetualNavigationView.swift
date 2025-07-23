import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualNavigationView: View {
    
    @State private var positionsRequest: PerpetualPositionsRequest
    @State private var positions: [PerpetualPositionData] = []
    
    let perpetual: Perpetual
    let wallet: Wallet
    let perpetualService: PerpetualServiceable
    
    public init(
        perpetual: Perpetual,
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        self.perpetual = perpetual
        self.wallet = wallet
        self.perpetualService = perpetualService
        _positionsRequest = State(initialValue: PerpetualPositionsRequest(walletId: wallet.id, perpetualId: perpetual.id))
    }
    
    public var body: some View {
        PerpetualScene(
            model: PerpetualSceneViewModel(
                wallet: wallet,
                perpetualViewModel: PerpetualViewModel(perpetual: positions.first?.perpetual ?? perpetual),
                positionViewModels: positions.flatMap { $0.positions }.map {
                    PerpetualPositionViewModel(position: $0)
                },
                perpetualService: perpetualService
            )
        )
        .observeQuery(request: $positionsRequest, value: $positions)
        .task {
            Task {
                try await perpetualService.updateMarkets()
                try await perpetualService.updatePositions(wallet: wallet)
            }
        }
    }
}
