import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService
import ActivityService

public struct PerpetualsNavigationView: View {
    @State private var model: PerpetualsSceneViewModel

    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        observerService: HyperliquidObserverService,
        activityService: ActivityService,
        onSelectAssetType: @escaping (SelectAssetType) -> Void,
        onSelectAsset: @escaping (Asset) -> Void
    ) {
        _model = State(
            initialValue: PerpetualsSceneViewModel(
                wallet: wallet,
                perpetualService: perpetualService,
                observerService: observerService,
                activityService: activityService,
                onSelectAssetType: onSelectAssetType,
                onSelectAsset: onSelectAsset
            )
        )
    }

    public var body: some View {
        PerpetualsScene(model: model)
            .observeQuery(request: $model.positionsRequest, value: $model.positions)
            .observeQuery(request: $model.perpetualsRequest, value: $model.perpetuals)
            .observeQuery(request: $model.walletBalanceRequest, value: $model.walletBalance)
            .observeQuery(request: $model.recentsRequest, value: $model.recents)
    }
}
