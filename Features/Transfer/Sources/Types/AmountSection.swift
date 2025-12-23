// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import PrimitivesComponents
import Primitives
import Staking

enum AmountSectionType: String, Identifiable, Equatable {
    case input
    case balance
    case info
    case options

    public var id: String { rawValue }
}

public enum AmountItem: Identifiable, Equatable, Sendable {
    case input
    case balance
    case info
    case validator
    case resource
    case leverage
    case autoclose

    public var id: Self { self }
}

public enum AmountItemModel {
    case input
    case balance(AmountBalanceItemModel)
    case info(AmountInfoItemModel)
    case validator(AmountValidatorItemModel)
    case resource(AmountResourceItemModel)
    case leverage(ListItemModel)
    case autoclose(ListItemModel)
    case empty
}

public struct AmountBalanceItemModel {
    let assetImage: AssetImage
    let assetName: String
    let balanceText: String
    let maxTitle: String
}

public struct AmountInfoItemModel {
    let text: String
}

public struct AmountValidatorItemModel {
    let validator: StakeValidatorViewModel
    let isSelectable: Bool
}

public struct AmountResourceItemModel {
    let resources: [ResourceViewModel]
}

extension ListSection where T == AmountItem {
    init(type: AmountSectionType, title: String? = nil, _ items: [AmountItem]) {
        self.init(type: type, title: title, values: items)
    }
}
