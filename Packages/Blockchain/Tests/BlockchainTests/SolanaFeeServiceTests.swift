// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import PrimitivesTestKit

@testable import Blockchain

struct SolanaFeeServiceTests {
    let service = SolanaFeeService()
    
    @Test
    func testGetBaseFeeForTransfer() throws {
        let gasPrice = GasPriceType.eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(10000))
        
        let fee = try service.getBaseFee(type: .transfer(.mock()), gasPrice: gasPrice)
        
        #expect(fee.fee == BigInt(15000)) // 5000 + 10000
        #expect(fee.gasLimit == BigInt(100_000))
        #expect(fee.gasPriceType == gasPrice)
    }
    
    @Test
    func testGetBaseFeeForStake() throws {
        let gasPrice = GasPriceType.eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(8000))
        
        let fee = try service.getBaseFee(type: .stake(.mock(), .stake(validator: .mock())), gasPrice: gasPrice)
        
        #expect(fee.fee == BigInt(13000)) // 5000 + 8000
        #expect(fee.gasLimit == BigInt(100_000))
        #expect(fee.gasPriceType == gasPrice)
    }
    
    @Test
    func testGetBaseFeeForSwap() throws {
        let gasPrice = GasPriceType.eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(15000))
        
        let fee = try service.getBaseFee(type: .swap(.mock(), .mock(), .mock()), gasPrice: gasPrice)
        
        #expect(fee.fee == BigInt(20000)) // 5000 + 15000
        #expect(fee.gasLimit == BigInt(420_000))
        #expect(fee.gasPriceType == gasPrice)
    }
    
    @Test
    func testGetBaseFeeForGeneric() throws {
        let gasPrice = GasPriceType.eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(12000))
        
        let fee = try service.getBaseFee(type: .generic(asset: .mock(), metadata: .mock(), extra: .mock()), gasPrice: gasPrice)
        
        #expect(fee.fee == BigInt(17000)) // 5000 + 12000
        #expect(fee.gasLimit == BigInt(420_000))
        #expect(fee.gasPriceType == gasPrice)
    }
    
    @Test
    func testFeeRatesForNativeTransfer() throws {
        let prioritizationFees = [50_000, 60_000, 70_000, 80_000, 90_000]
        
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .native)),
            prioritizationFees: prioritizationFees
        )
        
        #expect(feeRates.count == 3)
        
        // Priority fee base should be average: (50_000 + 60_000 + 70_000 + 80_000 + 90_000) / 5 = 70_000
        // Rounded to nearest 25_000 up = 75_000
        let expectedPriorityFeeBase = BigInt(75_000)
        let gasLimit = BigInt(100_000)
        
        // slow: priorityFeeBase / 2 * gasLimit / 1_000_000 = 75_000 / 2 * 100_000 / 1_000_000 = 3750
        let expectedSlowPriorityFee = (expectedPriorityFeeBase / 2 * gasLimit) / BigInt(1_000_000)
        // normal: priorityFeeBase * gasLimit / 1_000_000 = 75_000 * 100_000 / 1_000_000 = 7500
        let expectedNormalPriorityFee = (expectedPriorityFeeBase * gasLimit) / BigInt(1_000_000)
        // fast: priorityFeeBase * 3 * gasLimit / 1_000_000 = 75_000 * 3 * 100_000 / 1_000_000 = 22500
        let expectedFastPriorityFee = (expectedPriorityFeeBase * 3 * gasLimit) / BigInt(1_000_000)
        
        #expect(feeRates[0].priority == .slow)
        #expect(feeRates[0].gasPriceType.gasPrice == BigInt(5000))
        #expect(feeRates[0].gasPriceType.priorityFee == expectedSlowPriorityFee)
        
        #expect(feeRates[1].priority == .normal)
        #expect(feeRates[1].gasPriceType.gasPrice == BigInt(5000))
        #expect(feeRates[1].gasPriceType.priorityFee == expectedNormalPriorityFee)
        
        #expect(feeRates[2].priority == .fast)
        #expect(feeRates[2].gasPriceType.gasPrice == BigInt(5000))
        #expect(feeRates[2].gasPriceType.priorityFee == expectedFastPriorityFee)
    }
    
    @Test
    func testFeeRatesForTokenTransfer() throws {
        let prioritizationFees = [40_000, 50_000, 60_000]
        
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .spl)),
            prioritizationFees: prioritizationFees
        )
        
        #expect(feeRates.count == 3)
        
        // Priority fee base should be average: (40_000 + 50_000 + 60_000) / 3 = 50_000
        // Rounded to nearest 50_000 up = 50_000
        let expectedPriorityFeeBase = BigInt(50_000)
        let gasLimit = BigInt(100_000)
        
        let expectedSlowPriorityFee = (expectedPriorityFeeBase / 2 * gasLimit) / BigInt(1_000_000)
        let expectedNormalPriorityFee = (expectedPriorityFeeBase * gasLimit) / BigInt(1_000_000)
        let expectedFastPriorityFee = (expectedPriorityFeeBase * 3 * gasLimit) / BigInt(1_000_000)
        
        #expect(feeRates[0].gasPriceType.priorityFee == expectedSlowPriorityFee)
        #expect(feeRates[1].gasPriceType.priorityFee == expectedNormalPriorityFee)
        #expect(feeRates[2].gasPriceType.priorityFee == expectedFastPriorityFee)
    }
    
    @Test
    func testFeeRatesForSwap() throws {
        let prioritizationFees = [80_000, 120_000, 160_000]
        
        let feeRates = try service.feeRates(
            type: .swap(.mock(), .mock(), .mock()),
            prioritizationFees: prioritizationFees
        )
        
        #expect(feeRates.count == 3)
        
        // Priority fee base should be average: (80_000 + 120_000 + 160_000) / 3 = 120_000
        // Rounded to nearest 100_000 up = 200_000
        let expectedPriorityFeeBase = BigInt(200_000)
        let gasLimit = BigInt(420_000)
        
        let expectedSlowPriorityFee = (expectedPriorityFeeBase / 2 * gasLimit) / BigInt(1_000_000)
        let expectedNormalPriorityFee = (expectedPriorityFeeBase * gasLimit) / BigInt(1_000_000)
        let expectedFastPriorityFee = (expectedPriorityFeeBase * 3 * gasLimit) / BigInt(1_000_000)
        
        #expect(feeRates[0].gasPriceType.priorityFee == expectedSlowPriorityFee)
        #expect(feeRates[1].gasPriceType.priorityFee == expectedNormalPriorityFee)
        #expect(feeRates[2].gasPriceType.priorityFee == expectedFastPriorityFee)
    }
    
    @Test
    func testFeeRatesWithEmptyPrioritizationFees() throws {
        let prioritizationFees: [Int] = []
        
        let feeRates = try service.feeRates(
            type: .transfer(.mock(type: .native)),
            prioritizationFees: prioritizationFees
        )
        
        #expect(feeRates.count == 3)
        
        // When prioritizationFees is empty, should use multipleOf (25_000 for native transfer)
        let expectedPriorityFeeBase = BigInt(25_000)
        let gasLimit = BigInt(100_000)
        
        let expectedSlowPriorityFee = (expectedPriorityFeeBase / 2 * gasLimit) / BigInt(1_000_000)
        let expectedNormalPriorityFee = (expectedPriorityFeeBase * gasLimit) / BigInt(1_000_000)
        let expectedFastPriorityFee = (expectedPriorityFeeBase * 3 * gasLimit) / BigInt(1_000_000)
        
        #expect(feeRates[0].gasPriceType.priorityFee == expectedSlowPriorityFee)
        #expect(feeRates[1].gasPriceType.priorityFee == expectedNormalPriorityFee)
        #expect(feeRates[2].gasPriceType.priorityFee == expectedFastPriorityFee)
    }
    
    @Test
    func testGasLimitForDifferentTypes() {
        // Transfer types should use 100_000 gas limit
        let transferTypes: [TransferDataType] = [
            .transfer(.mock()),
            .stake(.mock(), .stake(validator: .mock())),
            .transferNft(.mock())
        ]
        
        for type in transferTypes {
            let fee = try! service.getBaseFee(
                type: type,
                gasPrice: .eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(1000))
            )
            #expect(fee.gasLimit == BigInt(100_000))
        }
        
        // Generic and swap types should use 420_000 gas limit
        let highGasTypes: [TransferDataType] = [
            .generic(asset: .mock(), metadata: .mock(), extra: .mock()),
            .swap(.mock(), .mock(), .mock())
        ]
        
        for type in highGasTypes {
            let fee = try! service.getBaseFee(
                type: type,
                gasPrice: .eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(1000))
            )
            #expect(fee.gasLimit == BigInt(420_000))
        }
    }
}