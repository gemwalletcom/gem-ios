// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Delegation: Identifiable {
    public var id: String {
        base.id
    }
}

extension DelegationBase: Identifiable {
    public var id: String {
        [assetId.identifier, validatorId, state.rawValue, delegationId].joined(separator: "_")
    }
}

extension DelegationValidator: Identifiable {}

public extension DelegationBase {
    
    var balanceValue: BigInt {
        BigInt(stringLiteral: balance)
    }

    var sharesValue: BigInt {
        BigInt(stringLiteral: shares)
    }

    var rewardsValue: BigInt {
        BigInt(stringLiteral: rewards)
    }
}

extension DelegationValidator {
    public static let systemId = "unstaking"

    public static func system(chain: Chain, name: String) -> DelegationValidator {
        DelegationValidator(
            chain: chain,
            id: systemId,
            name: name,
            isActive: true,
            commision: .zero,
            apr: .zero
        )
    }

    public var isSystem: Bool {
        id == Self.systemId
    }
}
