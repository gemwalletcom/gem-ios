import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualNavigationView: View {
    
    @State private var model: PerpetualSceneViewModel
    
    public init(
        perpetual: Perpetual,
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        _model = State(initialValue: PerpetualSceneViewModel(
            wallet: wallet,
            perpetual: perpetual,
            perpetualService: perpetualService
        ))
    }
    
    public var body: some View {
        PerpetualScene(model: model)
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
            .task {
                await model.fetch()
            }
    }
}
