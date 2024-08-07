// Copyright (c). Gem Wallet. All rights reserved.

import BigInt

enum FeeUnitType {
    case satVb
    case satB
}

struct FeeUnit {
    let unitType: FeeUnitType
    let value: BigInt
}
