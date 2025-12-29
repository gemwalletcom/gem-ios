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
                    if case .perpetual(let perpetual) = model.provider,
                       let leverageSelection = perpetual.leverageSelection {
                        LeveragePickerSheet(
                            title: perpetual.leverageTitle,
                            leverageOptions: leverageSelection.options,
                            selectedLeverage: Binding(
                                get: { leverageSelection.selected },
                                set: { newValue in
                                    leverageSelection.selected = newValue
                                    model.onLeverageChanged()
                                }
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
            .navigationDestination(for: DelegationValidator.self) { validator in
                if case .stake(let stake) = model.provider {
                    StakeValidatorsScene(
                        model: StakeValidatorsViewModel(
                            type: stake.validatorSelection.type,
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
