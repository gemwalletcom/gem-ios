// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Staking
import InfoSheet
import Components
import FiatConnect
import PrimitivesComponents
import Store
import Perpetuals

public struct AmountNavigationView: View {
    @State private var model: AmountSceneViewModel

    public init(model: AmountSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        AmountScene(model: model)
            .onChangeObserveQuery(
                request: $model.assetRequest,
                value: $model.assetData,
                action: model.onChangeAssetBalance
            )
            .sheet(item: $model.isPresentingSheet) {
                switch $0 {
                case let .infoAction(type):
                    InfoSheetScene(type: type)
                case .fiatConnect(let assetAddress, let walletId):
                    NavigationStack {
                        FiatConnectNavigationView(
                            model: FiatSceneViewModel(assetAddress: assetAddress, walletId: walletId.id)
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarDismissItem(title: .done, placement: .topBarLeading) }
                    }
                case .leverageSelector:
                    if let perpetualModel = model.amountTypeModel.perpetual {
                        LeveragePickerSheet(
                            title: perpetualModel.selectionTitle,
                            leverageOptions: perpetualModel.items,
                            selectedLeverage: Binding(
                                get: { perpetualModel.selectedItem ?? LeverageOption(value: 1) },
                                set: { perpetualModel.selectedItem = $0 }
                            )
                        )
                    }
                case .autoclose(let openData):
                    AutocloseSheet(
                        openData: openData,
                        onComplete: model.onAutocloseComplete
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(model.nextTitle, action: model.onSelectNextButton)
                        .bold()
                        .disabled(!model.isNextEnabled)
                }
            }
            .navigationDestination(for: DelegationValidator.self) { value in
                if let stakingModel = model.amountTypeModel.staking {
                    StakeValidatorsScene(
                        model: StakeValidatorsViewModel(
                            type: stakingModel.stakeValidatorsType,
                            chain: model.asset.chain,
                            currentValidator: value,
                            validators: stakingModel.items,
                            selectValidator: model.onSelectValidator
                        )
                    )
                }
            }
    }
}
