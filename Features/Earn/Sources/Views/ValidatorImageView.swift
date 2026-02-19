// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Style

public struct ValidatorImageView: View {

    private let validator: DelegationValidator
    private let formatter = AssetImageFormatter()

    public init(validator: DelegationValidator) {
        self.validator = validator
    }

    public var body: some View {
        switch validator.providerType {
        case .stake:
            AsyncImageView(
                url: formatter.getValidatorUrl(chain: validator.chain, id: validator.id),
                size: .image.asset,
                placeholder: .letter(validator.name.first ?? " ")
            )
        case .earn:
            let image = YieldProvider(rawValue: validator.id).map { YieldProviderViewModel(provider: $0).image } ?? Images.Logo.logo
            image
                .resizable()
                .frame(width: Sizing.image.asset, height: Sizing.image.asset)
                .clipShape(Circle())
        }
    }
}
