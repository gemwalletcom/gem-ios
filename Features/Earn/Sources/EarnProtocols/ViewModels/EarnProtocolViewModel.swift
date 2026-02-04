// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Foundation
import Localization
import Primitives
import PrimitivesComponents
import SwiftUI

@Observable
public final class EarnProtocolViewModel: Sendable {
    public let name: String
    public let assetId: AssetId
    public let provider: EarnProvider
    public let apy: Double?

    public init(protocol: EarnProtocol) {
        self.name = `protocol`.name
        self.assetId = `protocol`.assetId
        self.provider = `protocol`.provider
        self.apy = `protocol`.apy
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

extension EarnProtocolViewModel: Identifiable {
    public var id: String {
        "\(provider.name)-\(assetId)"
    }
}
