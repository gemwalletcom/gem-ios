// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

extension EarnData {
    public static func mock(
        contractAddress: String = "",
        callData: String = "",
        approval: ApprovalData? = nil,
        gasLimit: String? = nil
    ) -> EarnData {
        EarnData(
            contractAddress: contractAddress,
            callData: callData,
            approval: approval,
            gasLimit: gasLimit
        )
    }
}
