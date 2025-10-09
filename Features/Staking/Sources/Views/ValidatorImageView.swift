// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GemstonePrimitives

public struct ValidatorImageView: View {
    
    private let validator: DelegationValidator
    private let formatter = AssetImageFormatter()
    
    public init(validator: DelegationValidator) {
        self.validator = validator
    }
    
    public var body: some View {
        AsyncImageView(
            url: formatter.getValidatorUrl(chain: validator.chain, id: validator.id),
            size: .image.asset,
            placeholder: .letter(validator.name.first ?? " ")
        )
    }
}
