import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService

public struct PerpetualsNavigationView: View {
    @State private var model: PerpetualsSceneViewModel

    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        isPresentingSelectAssetType: Binding<SelectAssetType?>
    ) {
        _model = State(
            initialValue: PerpetualsSceneViewModel(
                wallet: wallet,
                perpetualService: perpetualService,
                onSelectAssetType: { isPresentingSelectAssetType.wrappedValue = $0 }
            )
        )
    }

    public var body: some View {
        PerpetualsScene(model: model)
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
            .observeQuery(request: $model.perpetualsRequest, value: $model.perpetuals)
            .observeQuery(request: $model.walletBalanceRequest, value: $model.walletBalance)
    }
}
