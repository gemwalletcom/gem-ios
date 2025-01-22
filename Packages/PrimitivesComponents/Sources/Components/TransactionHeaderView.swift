// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

public enum TransactionHeaderType {
    case amount(title: String, subtitle: String?)
    case swap(from: SwapAmountField, to: SwapAmountField)
    
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
        }
    }
}
