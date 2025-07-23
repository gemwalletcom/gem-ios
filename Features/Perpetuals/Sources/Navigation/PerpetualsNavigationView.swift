import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualsNavigationView: View {
    
    @State private var positionsRequest: PerpetualPositionsRequest
    @State private var perpetualsRequest: PerpetualsRequest
    @State private var positions: [PerpetualPositionData] = []
    @State private var perpetuals: [Perpetual] = []
    
    let wallet: Wallet
    let perpetualService: PerpetualServiceable
    
    private let updateTimer = Timer.publish(every: 5, tolerance: 1, on: .main, in: .common).autoconnect()
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        _positionsRequest = State(initialValue: PerpetualPositionsRequest(walletId: wallet.id))
        _perpetualsRequest = State(initialValue: PerpetualsRequest())
    }
    
    public var body: some View {
        PerpetualsScene(
            model: PerpetualsSceneViewModel(
                wallet: wallet,
                perpetualService: perpetualService,
                positions: positions,
                perpetuals: perpetuals
            )
        )
        .observeQuery(request: $positionsRequest, value: $positions)
        .observeQuery(request: $perpetualsRequest, value: $perpetuals)
        .task {
            await updateData()
        }
        .onReceive(updateTimer) { _ in
            Task {
                await updateData()
            }
        }
        .refreshable {
            await updateData()
        }
    }
    
    private func updateData() async {
        await updateMarkets()
        await updatePositions()
    }
    
    private func updateMarkets() async {
        do {
            try await perpetualService.updateMarkets()
        } catch {
            print("Failed to update markets: \(error)")
        }
    }
    
    private func updatePositions() async {
        do {
            try await perpetualService.updatePositions(wallet: wallet)
        } catch {
            print("Failed to update positions: \(error)")
        }
    }
}
