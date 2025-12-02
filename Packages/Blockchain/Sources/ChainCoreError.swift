// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives
import Gemstone

public enum ChainCoreError: String, Error, Equatable {
    case feeRateMissed
    case cantEstimateFee
    case incorrectAmount
    case dustThreshold

    public static func fromWalletCore(_ error: CommonSigningError) throws {
        let chainError: ChainCoreError? = switch error {
        case .errorDustAmountRequested,
            .errorNotEnoughUtxos,
            .errorMissingInputUtxos: ChainCoreError.dustThreshold
        case .ok: .none
        default: ChainCoreError.cantEstimateFee
        }

        if let error = chainError {
            throw error
        }
    }
    
    
    public static func fromError(_ error: Error) -> ChainCoreError? {
        for errorCase in [ChainCoreError.dustThreshold, .feeRateMissed, .cantEstimateFee, .incorrectAmount] {
            if error.localizedDescription.contains(errorCase.rawValue) {
                return errorCase
            }
        }

        return nil
    }
}
