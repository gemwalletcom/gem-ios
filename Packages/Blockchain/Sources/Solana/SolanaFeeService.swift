// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

struct SolanaFeeService {
    private let staticBaseFee = BigInt(5000)
    
    // https://solana.com/docs/core/fees#compute-unit-limit
    func getBaseFee(type: TransferDataType, gasPrice: GasPriceType) throws -> Fee {
        Fee(
            fee: gasPrice.gasPrice + gasPrice.priorityFee,
            gasPriceType: gasPrice,
            gasLimit: gasLimit(for: type)
        )
    }
    
    func feeRates(
        type: TransferDataType,
        prioritizationFees: [Int]
    ) throws -> [FeeRate] {
        // filter out any large fees
        let priorityFees = prioritizationFees.map { $0 }.sorted(by: >).prefix(5)
        
        let multipleOf = switch type {
        case .transfer(let asset), .deposit(let asset): asset.type == .native ? 25_000 : 50_000
        case .stake, .transferNft: 25_000
        case .generic, .swap: 100_000
        case .account, .tokenApprove, .perpetual, .withdrawal: fatalError()
        }
        
        let priorityFeeBase = {
            if priorityFees.isEmpty {
                BigInt(multipleOf)
            } else {
                BigInt(
                    max(
                        (priorityFees.reduce(0, +) / priorityFees.count).roundToNearest(
                            multipleOf: multipleOf,
                            mode: .up
                        ),
                        multipleOf
                    )
                )
            }
        }()
        
        return [FeePriority.slow, FeePriority.normal, FeePriority.fast].map {
            let priorityFee = switch $0 {
            case .slow: priorityFeeBase / 2
            case .normal: priorityFeeBase
            case .fast: priorityFeeBase * 3
            }
            return FeeRate(
                priority: $0,
                gasPriceType: .eip1559(
                    gasPrice: staticBaseFee,
                    priorityFee: (priorityFee * gasLimit(for: type)) / BigInt(1_000_000)
                )
            )
        }
    }
    
    // MARK: - Private methods
    
    private func gasLimit(for type: TransferDataType) -> BigInt {
        switch type {
        case .transfer, .deposit, .stake, .transferNft: BigInt(100_000)
        case .generic, .swap: BigInt(420_000)
        case .account, .tokenApprove, .perpetual, .withdrawal: fatalError()
        }
    }
}
