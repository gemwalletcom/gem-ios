import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService
import Perpetuals

public struct PerpetualNavigationView: View {
    @State private var model: PerpetualSceneViewModel
    @Binding var isPresentingConfirmTransfer: ConfirmTransferPresentation?
    @Binding var isPresentingPerpetualRecipientData: PerpetualRecipientData?

    public init(
        perpetualData: PerpetualData,
        wallet: Wallet,
        perpetualService: any PerpetualServiceable,
        isPresentingConfirmTransfer: Binding<ConfirmTransferPresentation?>,
        isPresentingPerpetualRecipientData: Binding<PerpetualRecipientData?>
    ) {
        _isPresentingConfirmTransfer = isPresentingConfirmTransfer
        _isPresentingPerpetualRecipientData = isPresentingPerpetualRecipientData
        _model = State(initialValue: PerpetualSceneViewModel(
            wallet: wallet,
            perpetualData: perpetualData,
            perpetualService: perpetualService,
            onTransferData: { isPresentingConfirmTransfer.wrappedValue = .confirm($0) },
            onPerpetualRecipientData: { isPresentingPerpetualRecipientData.wrappedValue = $0 }
        ))
    }

    public var body: some View {
        PerpetualScene(model: model)
            .sheet(isPresented: $model.isPresentingAutoclose) {
                if let position = model.positions.first {
                    AutocloseNavigationStack(
                        position: position,
                        wallet: model.wallet,
                        onComplete: model.onAutocloseComplete
                    )
                }
            }
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
            .observeQuery(request: $model.transactionsRequest, value: $model.transactions)
            .observeQuery(request: $model.perpetualTotalValueRequest, value: $model.perpetualTotalValue)
            // we should ideally observer is isCompleted, but don't have access from here
            .onChange(of: isPresentingConfirmTransfer) { _, newValue in
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
