import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualNavigationView: View {
    
    @State private var model: PerpetualSceneViewModel
    @Binding var isPresentingTransferData: TransferData?
    @Binding var isPresentingPerpetualRecipientData: PerpetualRecipientData?
    
    public init(
        perpetualData: PerpetualData,
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        isPresentingTransferData: Binding<TransferData?>,
        isPresentingPerpetualRecipientData: Binding<PerpetualRecipientData?>
    ) {
        _isPresentingTransferData = isPresentingTransferData
        _isPresentingPerpetualRecipientData = isPresentingPerpetualRecipientData
        _model = State(initialValue: PerpetualSceneViewModel(
            wallet: wallet,
            perpetualData: perpetualData,
            perpetualService: perpetualService,
            onTransferData: { isPresentingTransferData.wrappedValue = $0 },
            onPerpetualRecipientData: { isPresentingPerpetualRecipientData.wrappedValue = $0 }
        ))
    }

    public var body: some View {
        PerpetualScene(model: model)
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
            .observeQuery(request: $model.transactionsRequest, value: $model.transactions)
            .observeQuery(request: $model.perpetualTotalValueRequest, value: $model.perpetualTotalValue)
            // we should ideally observer is isCompleted, but don't have access from here
            .onChange(of: isPresentingTransferData) { _, newValue in
                if newValue == .none {
                    Task { await model.fetch() }
                }
            }
            .onChange(of: isPresentingPerpetualRecipientData) { _, newValue in
                if newValue == .none {
                    Task { await model.fetch() }
                }
            }
    }
}
