// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct AmountView: View {
    private let viewModel: any AmountDisplayable

    public init(viewModel: any AmountDisplayable) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(viewModel.amount.text)
                .foregroundStyle(Colors.black)
                .font(.system(size: 52))
                .scaledToFit()
                .fontWeight(viewModel.amount.style.fontWeight ?? .semibold)
                .minimumScaleFactor(0.4)
                .truncationMode(.middle)
                .lineLimit(1)

            if let fiat = viewModel.fiat {
                Text(fiat.text)
                    .font(.system(size: 16))
                    .fontWeight(viewModel.fiat?.style.fontWeight ?? .medium)
                    .foregroundStyle(viewModel.fiat?.style.color ?? Colors.gray)
            }
        }
    }
}
