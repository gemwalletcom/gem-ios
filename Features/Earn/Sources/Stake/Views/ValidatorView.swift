// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

public struct ValidatorView: View {

    private let model: StakeValidatorViewModel

    public init(model: StakeValidatorViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            ValidatorImageView(validator: model.validator)
            ListItemView(
                title: model.name,
                subtitle: model.aprText
            )
        }
    }
}
