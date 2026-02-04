// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Foundation
import Gemstone
import Localization
import SwiftUI

@Observable
public final class EarnProtocolViewModel: Identifiable, Sendable {
    public let name: String
    public let assetId: Gemstone.AssetId
    public let provider: GemYieldProvider
    public let apy: Double?

    public init(yield: GemYield) {
        self.name = yield.name
        self.assetId = yield.assetId
        self.provider = yield.provider
        self.apy = yield.apy
    }

    public var id: String {
        "\(provider.name)-\(assetId)"
    }

    public var providerName: String {
        provider.displayName
    }

    public var apyText: String {
        guard let apy = apy else {
            return "--"
        }
        return Localized.Stake.apr(CurrencyFormatter.percentSignLess.string(apy))
    }

    public var hasApy: Bool {
        apy != nil
    }

    public var providerImage: Image {
        provider.image
    }
}
