// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Earn
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
                case let .fiatConnect(assetAddress, walletId):
                    NavigationStack {
                        FiatConnectNavigationView(
                            model: FiatSceneViewModel(assetAddress: assetAddress, walletId: walletId)
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarDismissItem(type: .close, placement: .topBarLeading) }
                    }
                case let .leverageSelector(selection):
                    @Bindable var leverageSelection = selection
                    LeveragePickerSheet(
                        title: leverageSelection.title,
                        leverageOptions: leverageSelection.options,
                        selectedLeverage: $leverageSelection.selected
                    )
                    .onChange(of: leverageSelection.selected, model.onChangeLeverage)
                case let .autoclose(openData):
                    AutocloseSheet(
                        openData: openData,
                        onComplete: model.onAutocloseComplete
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(model.continueTitle, action: model.onSelectNextButton)
                        .bold()
                        .disabled(!model.isNextEnabled)
                }
            }
            .navigationDestination(for: DelegationValidator.self) { validator in
                if case let .stake(stake) = model.provider {
                    StakeValidatorsScene(
                        model: StakeValidatorsViewModel(
                            type: stake.stakeValidatorsType,
                            chain: model.asset.chain,
                            currentValidator: validator,
                            validators: stake.validatorSelection.options,
                            selectValidator: model.onValidatorSelected
                        )
                    )
                }
            }
    }
}
