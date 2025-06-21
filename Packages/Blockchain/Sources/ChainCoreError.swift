// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

public enum ChainCoreError: Error, Equatable {
    case feeRateMissed
    case cantEstimateFee
    case incorrectAmount    
    case dustThreshold(chain: Chain)
    
    public static func fromWalletCore(for chain: Chain, _ error: CommonSigningError) throws {
        let chainError: ChainCoreError? = switch error {
        case .errorDustAmountRequested,
            .errorNotEnoughUtxos: ChainCoreError.dustThreshold(chain: chain)
        case .ok: .none
        default: ChainCoreError.cantEstimateFee
        }
        
        if let error = chainError {
            throw error
        }
    }
}
