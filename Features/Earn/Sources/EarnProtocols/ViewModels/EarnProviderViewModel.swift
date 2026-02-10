// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Foundation
import Localization
import Primitives
import PrimitivesComponents
import Style
import SwiftUI

@Observable
public final class EarnProviderViewModel: Sendable {
    public let earnProvider: DelegationValidator

    public init(provider: DelegationValidator) {
        self.earnProvider = provider
    }

    public var providerName: String {
        earnProvider.name
    }

    public var apyText: String {
        guard earnProvider.apr > 0 else {
            return "--"
        }
        return Localized.Stake.apr(CurrencyFormatter.percentSignLess.string(earnProvider.apr))
    }

    public var hasApy: Bool {
        earnProvider.apr > 0
    }

    public var providerImage: Image {
        YieldProvider(rawValue: earnProvider.id)?.image ?? Images.Logo.logo
    }
}

extension EarnProviderViewModel: Identifiable {
    public var id: String {
        "\(earnProvider.id)-\(earnProvider.chain.rawValue)"
    }
}
