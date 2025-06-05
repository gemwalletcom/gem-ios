// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Staking

public struct AmountNavigationView: View {
    @State private var model: AmountSceneViewModel

    public init(model: AmountSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        AmountScene(
            model: model
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    model.nextTitle,
                    action: model.onSelectNextButton
                )
                .bold()
                .disabled(!model.isNextEnabled)
            }
        }
        .navigationDestination(for: $model.delegation) { value in
            StakeValidatorsScene(
                model: StakeValidatorsViewModel(
                    type: model.stakeValidatorsType,
                    chain: model.asset.chain,
                    currentValidator: value,
                    validators: model.validators,
                    selectValidator: model.onSelectValidator
                )
            )
        }
    }
}
