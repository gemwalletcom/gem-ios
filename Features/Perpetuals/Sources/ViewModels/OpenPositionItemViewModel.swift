// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Formatters

public struct OpenPositionItemViewModel: ListAssetItemViewable {
    private let data: AutocloseOpenData
    private let currencyFormatter: CurrencyFormatter

    public var action: ((ListAssetItemAction) -> Void)?

    public init(data: AutocloseOpenData) {
        self.data = data
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
    }

    public var name: String { data.symbol }
    public var symbol: String? { nil }

    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: data.assetId).assetImage
    }

    public var subtitleView: ListAssetItemSubtitleView {
        .type(
            TextValue(
                text: positionTypeText,
                style: TextStyle(font: .footnote, color: directionViewModel.color)
            )
        )
    }

    public var rightView: ListAssetItemRightView {
        .balance(
            balance: TextValue(
                text: currencyFormatter.string(data.size),
                style: TextStyle(font: .body, color: .primary, fontWeight: .medium)
            ),
            totalFiat: TextValue(
                text: "",
                style: TextStyle(font: .footnote, color: Colors.secondaryText)
            )
        )
    }
}

extension OpenPositionItemViewModel {
    private var directionViewModel: PerpetualDirectionViewModel {
        PerpetualDirectionViewModel(direction: data.direction)
    }

    private var positionTypeText: String {
        "\(directionViewModel.title.uppercased()) \(Int(data.leverage))x"
    }
}
