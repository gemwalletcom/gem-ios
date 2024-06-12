// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct EthereumStakeService {
    let service: EthereumService

    public init(
        service: EthereumService
    ) {
        self.service = service
    }

    func getGasLimit(chain: EVMChain, type: StakeType, stakeValue: BigInt, from: String, to: String, value: BigInt?, data: Data?) async throws -> BigInt {
        switch chain {
        case .ethereum:
            switch type {
            case .unstake:
                // Avoid siging permit at preload stage, withdrawLimit is pretty a constant for 1 amount
                return BigInt(LidoContract.withdrawLimit)
            default:
                break
            }
        case .smartChain:
            break
        default:
            fatalError()
        }
        return try await service.getGasLimit(from: from, to: to, value: value?.hexString.append0x, data: data?.hexString.append0x)
    }
}
