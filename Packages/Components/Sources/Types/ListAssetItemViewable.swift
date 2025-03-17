// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public enum ListAssetItemRightView {
    case balance(balance: TextValue, totalFiat: TextValue)
    case toggle(Bool)
    case copy
    case none
}

public enum ListAssetItemSubtitleView {
    case price(price: TextValue, priceChangePercentage24h: TextValue)
    case type(TextValue)
    case none
}

public enum ListAssetItemAction {
    case switcher(enabled: Bool)
    case copy
}

public protocol ListAssetItemViewable {
    var name: String { get }
    var symbol: String? { get }

    var assetImage: AssetImage { get }

    var subtitleView: ListAssetItemSubtitleView { get }
    var rightView: ListAssetItemRightView { get }

    var action: ((ListAssetItemAction) -> Void)? { get set }

    var showBalancePrivacy: Binding<Bool> { get }
}

extension ListAssetItemViewable {
    var isAssetEnabled: Bool {
        switch rightView {
        case .balance, .copy, .none: false
        case .toggle(let value): value
        }
    }
}
