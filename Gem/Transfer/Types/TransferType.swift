// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum AmountType: Equatable, Hashable {
    case transfer(recipient: RecipientData)
    case stake(validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case unstake(delegation: Delegation)
    case redelegate(delegation: Delegation, validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case withdraw(delegation: Delegation)
}

struct AmountInput {
    let type: AmountType
    let asset: Asset
}

extension AmountInput: Identifiable {
    var id: String {
        asset.id.identifier
    }
}

extension AmountInput: Hashable {}
