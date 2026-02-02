// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct ValidatorImageView: View {

    private let validator: DelegationValidator
    private let formatter = AssetImageFormatter()

    init(validator: DelegationValidator) {
        self.validator = validator
    }

    var body: some View {
        AsyncImageView(
            url: formatter.getValidatorUrl(chain: validator.chain, id: validator.id),
            size: .image.asset,
            placeholder: .letter(validator.name.first ?? " ")
        )
    }
}
