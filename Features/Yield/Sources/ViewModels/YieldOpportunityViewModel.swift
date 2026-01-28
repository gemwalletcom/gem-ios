// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Foundation
import Gemstone
import Localization
import Primitives
import Style
import SwiftUI

@Observable
public final class YieldOpportunityViewModel: Identifiable, Sendable {
    public let name: String
    public let assetId: Gemstone.AssetId
    public let provider: GemYieldProvider
    public let apy: Double?
    public let risk: GemRiskLevel

    public init(yield: GemYield) {
        self.name = yield.name
        self.assetId = yield.assetId
        self.provider = yield.provider
        self.apy = yield.apy
        self.risk = yield.risk
    }

    public init(position: GemYieldPosition) {
        self.name = position.name
        self.assetId = position.assetId
        self.provider = position.provider
        self.apy = position.apy
        self.risk = .medium
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

    public var riskText: String {
        risk.displayName
    }

    public var riskColor: Color {
        risk.color
    }

    public var riskDotsView: some View {
        let riskLevel = risk
        return HStack(spacing: Spacing.small) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < riskLevel.dotCount ? riskLevel.color : Colors.grayLight)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

extension GemYieldProvider {
    public var displayName: String {
        switch self {
        case .yo: "Yo"
        }
    }

    public var image: Image {
        switch self {
        case .yo: Images.YieldProviders.yo
        }
    }
}

extension GemRiskLevel {
    public var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    public var color: Color {
        switch self {
        case .low: Colors.green
        case .medium: Colors.orange
        case .high: Colors.red
        }
    }

    public var dotCount: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .high: 3
        }
    }
}
