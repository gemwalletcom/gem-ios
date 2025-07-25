import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualNavigationView: View {
    
    @State private var model: PerpetualSceneViewModel
    @Binding var isPresentingTransferData: TransferData?
    
    public init(
        perpetualData: PerpetualData,
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        isPresentingTransferData: Binding<TransferData?>
    ) {
        _isPresentingTransferData = isPresentingTransferData
        _model = State(initialValue: PerpetualSceneViewModel(
            wallet: wallet,
            perpetualData: perpetualData,
            perpetualService: perpetualService,
            onPresentTransferData: { isPresentingTransferData.wrappedValue = $0 }
        ))
    }
    
    public init(
        model: PerpetualSceneViewModel,
        isPresentingTransferData: Binding<TransferData?>
    ) {
        _isPresentingTransferData = isPresentingTransferData
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        PerpetualScene(model: model)
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
    }
}
