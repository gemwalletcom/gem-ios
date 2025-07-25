// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import PrimitivesTestKit

@testable import Blockchain

struct SolanaFeeServiceTests {
    let service = SolanaFeeService()
    
    let fee100_000 = Fee(fee: 15_000, gasPriceType: .mockEip1559(), gasLimit: 100_000)
    let fee420_000 = Fee(fee: 15_000, gasPriceType: .mockEip1559(), gasLimit: 420_000)
    
    @Test
    func getBaseFeeForTransfer() throws {
        #expect(try service.getBaseFee(type: .transfer(.mock()), gasPrice: .mockEip1559()) == fee100_000)
    }
    
    @Test
    func getBaseFeeForStake() throws {
        #expect(try service.getBaseFee(type: .stake(.mock(), .stake(validator: .mock())), gasPrice: .mockEip1559()) == fee100_000)
    }
    
    @Test
    func getBaseFeeForSwap() throws {
        #expect(try service.getBaseFee(type: .swap(.mock(), .mock(), .mock()), gasPrice: .mockEip1559()) == fee420_000)
    }
    
    @Test
    func getBaseFeeForGeneric() throws {
        #expect(try service.getBaseFee(type: .generic(asset: .mock(), metadata: .mock(), extra: .mock()), gasPrice: .mockEip1559()) == fee420_000)
    }
    
    @Test
    func feeRatesForNativeTransfer() throws {
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .native)),
            prioritizationFees: [60_000]
        )

        let normalRate = feeRates.first { $0.priority == .normal }
        #expect(normalRate?.priority == .normal)
        #expect(normalRate?.gasPriceType.gasPrice == BigInt(5_000))
        #expect(normalRate?.gasPriceType.priorityFee == BigInt(7_500))
    }
    
    @Test
    func feeRatesForTokenTransfer() throws {
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .spl)),
            prioritizationFees: [60_000]
        )

        let normalRate = feeRates.first { $0.priority == .normal }
        #expect(normalRate?.gasPriceType.priorityFee == BigInt(10_000))
    }
    
    @Test
    func feeRatesForSwap() throws {
        let feeRates = try service.feeRates(
            type: .swap(.mock(), .mock(), .mock()),
            prioritizationFees: [60_000]
        )
        
        let normalRate = feeRates.first { $0.priority == .normal }
        #expect(normalRate?.gasPriceType.priorityFee == BigInt(42_000))
    }
    
    @Test
    func feeRatesWithEmptyPrioritizationFees() throws {
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .native)),
            prioritizationFees: []
        )
        
        #expect(feeRates.first?.gasPriceType.priorityFee == BigInt(1_250))
    }
    
    @Test
    func feeRatesCount() throws {
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .native)),
            prioritizationFees: [1, 2 ,3, 4, 5]
        )
        
        #expect(feeRates.count == 3)
    }
}
