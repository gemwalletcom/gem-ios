// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct PerpetualOrderTypeViewModel: Identifiable, Sendable {
    public let type: PerpetualOrderType

    public init(_ type: PerpetualOrderType) {
        self.type = type
    }

    public var id: String { type.rawValue }

    // TODO: - Localize?
    public var title: String {
        switch type {
        case .market: "Market"
        case .limit: "Limit"
        }
    }
}
