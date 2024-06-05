// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct ValidatorImageView: View {
    
    let validator: DelegationValidator
    private let formatter = AssetImageFormatter()
    
    var body: some View {
        AsyncImageView(
            url: formatter.getValidatorUrl(chain: validator.chain, id: validator.id),
            placeholder: .letter(validator.name.first ?? " ")
        )
    }
}
