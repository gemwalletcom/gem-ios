// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import Style
import SwiftUI

@Observable
public final class YieldOpportunityViewModel: Identifiable, Sendable {
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

    public init(position: GemYieldPosition) {
        self.name = position.name
        self.assetId = position.assetId
        self.provider = position.provider
        self.apy = position.apy
    }

    public var id: String {
        "\(provider.name)-\(assetId)"
    }

    public var providerName: String {
        switch provider {
        case .yo:
            return "Yo"
        }
    }

    public var apyText: String {
        guard let apy = apy else {
            return "--"
        }
        let formatted = String(format: "%.2f", apy * 100)
        return "\(formatted)%"
    }

    public var hasApy: Bool {
        apy != nil
    }

    public var providerImage: Image {
        provider.image
    }
}

extension GemYieldProvider {
    public var image: Image {
        switch self {
        case .yo:
            return Images.YieldProviders.yo
        }
    }
}
