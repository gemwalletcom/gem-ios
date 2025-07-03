// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Style

public enum TransactionHeaderType {
    case amount(title: String, subtitle: String?)
    case swap(from: SwapAmountField, to: SwapAmountField)
    case nft(name: String?, image: AssetImage)
}

public struct TransactionHeaderView: View {
    
    public let type: TransactionHeaderType
    
    public init(type: TransactionHeaderType) {
        self.type = type
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            switch type {
            case .amount(let title, let subtitle):
                AmountView(
                    title: title,
                    subtitle: subtitle
                )
            case .swap(let from, let to):
                SwapAmountView(from: from, to: to)
            case .nft(let name, let image):
                VStack(spacing: .medium) {
                    NftImageView(assetImage: image)
                        .frame(width: .image.large, height: .image.large)
                        .cornerRadius(.image.large/4)
                    if let name {
                        Text(name)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
