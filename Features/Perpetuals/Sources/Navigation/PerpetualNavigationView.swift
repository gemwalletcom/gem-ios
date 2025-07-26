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
    
    public init(
        model: PerpetualSceneViewModel,
        isPresentingTransferData: Binding<TransferData?>,
        isPresentingPerpetualRecipientData: Binding<PerpetualRecipientData?>
    ) {
        _isPresentingTransferData = isPresentingTransferData
        _isPresentingPerpetualRecipientData = isPresentingPerpetualRecipientData
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        PerpetualScene(model: model)
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
    }
}
