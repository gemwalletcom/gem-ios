import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualsNavigationView: View {
    
    @State private var positionsRequest: PerpetualPositionsRequest
    @State private var perpetualsRequest: PerpetualsRequest
    @State private var perpetualTotalValueRequest: TotalValueRequest

    @State private var positions: [PerpetualPositionData] = []
    @State private var perpetuals: [PerpetualData] = []
    @State private var perpetualTotalValue: Double = .zero
    
    let wallet: Wallet
    let perpetualService: PerpetualServiceable
    @Binding var isPresentingSelectAssetType: SelectAssetType?
    @Binding var isPresentingTransferData: TransferData?
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        isPresentingSelectAssetType: Binding<SelectAssetType?>,
        isPresentingTransferData: Binding<TransferData?>
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        _isPresentingSelectAssetType = isPresentingSelectAssetType
        _isPresentingTransferData = isPresentingTransferData
        _positionsRequest = State(initialValue: PerpetualPositionsRequest(walletId: wallet.id))
        _perpetualsRequest = State(initialValue: PerpetualsRequest())
        _perpetualTotalValueRequest = State(initialValue: TotalValueRequest(walletId: wallet.id, balanceType: .perpetual))
    }
    
    public var body: some View {
        PerpetualsScene(
            model: PerpetualsSceneViewModel(
                wallet: wallet,
                perpetualService: perpetualService,
                positions: positions,
                perpetuals: perpetuals,
                perpetualTotalValue: perpetualTotalValue,
                onSelectAssetType: { isPresentingSelectAssetType = $0 },
                onTransferComplete: { isPresentingTransferData = $0 }
            )
        )
        .observeQuery(request: $positionsRequest, value: $positions)
        .observeQuery(request: $perpetualsRequest, value: $perpetuals)
        .observeQuery(request: $perpetualTotalValueRequest, value: $perpetualTotalValue)
    }
}
