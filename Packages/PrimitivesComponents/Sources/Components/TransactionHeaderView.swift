// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Style

public enum TransactionHeaderType {
    case amount(title: String, subtitle: String?)
    case swap(from: SwapAmountField, to: SwapAmountField)
    case nft(name: String, image: AssetImage)
    
    public static let swapValueFormatterStyle = ValueFormatter.Style.medium
}

public struct TransactionHeaderView: View {
    
    public let type: TransactionHeaderType
    
    public init(type: TransactionHeaderType) {
        self.type = type
    }
    
    public var body: some View {
        switch type {
        case .amount(let title, let subtitle):
            AmountView(
                title: title,
                subtitle: subtitle
            )
        case .swap(let from, let to):
            SwapAmountView(from: from, to: to)
        case .nft(let name, let image):
            VStack(spacing: Spacing.medium) {
                NftImageView(assetImage: image)
                    .frame(width: Sizing.image.large, height: Sizing.image.large)
                    .cornerRadius(Sizing.image.large/4)
                Text(name)
            }
        }
    }
}
