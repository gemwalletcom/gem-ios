// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import PrimitivesTestKit

@testable import Blockchain

struct TronFeeServiceTests {
    let service = TronFeeService()
    
    @Test
    func testNativeTransferFee() throws {
        // Test case 1: Existing account with sufficient bandwidth
        let accountUsage1 = TronAccountUsage(freeNetUsed: 100, freeNetLimit: 500, EnergyUsed: 0, EnergyLimit: 0)
        let accountUsage2 = TronAccountUsage(freeNetUsed: 300, freeNetLimit: 500, EnergyUsed: 0, EnergyLimit: 0)
        let parameters = [
            TronChainParameter(key: TronChainParameterKey.getCreateAccountFee.rawValue, value: 100),
            TronChainParameter(key: TronChainParameterKey.getCreateNewAccountFeeInSystemContract.rawValue, value: 200)
        ]
        
        let fee1 = try service.nativeTransferFee(
            accountUsage: accountUsage1,
            parameters: parameters,
            isNewAccount: false
        )
        #expect(fee1 == BigInt.zero)
        
        // Test case 2: Existing account with insufficient bandwidth
        let fee2 = try service.nativeTransferFee(
            accountUsage: accountUsage2,
            parameters: parameters,
            isNewAccount: false
        )
        #expect(fee2 == BigInt(280_000))
        
        // Test case 3: New account with sufficient bandwidth
        let fee3 = try service.nativeTransferFee(
            accountUsage: accountUsage1,
            parameters: parameters,
            isNewAccount: true
        )
        #expect(fee3 == BigInt(300))
        
        // Test case 4: New account with insufficient bandwidth
        let fee4 = try service.nativeTransferFee(
            accountUsage: accountUsage2,
            parameters: parameters,
            isNewAccount: true
        )
        #expect(fee4 == BigInt(280_300))
    }
    
    @Test
    func testTrc20TransferFee() throws {
        let accountUsage = TronAccountUsage(freeNetUsed: 500, freeNetLimit: 1000, EnergyUsed: 500, EnergyLimit: 1000)
        let parameters = [
            TronChainParameter(key: TronChainParameterKey.getEnergyFee.rawValue, value: 100),
            TronChainParameter(key: TronChainParameterKey.getCreateNewAccountFeeInSystemContract.rawValue, value: 200)
        ]
        
        // Test case 1: Existing account with sufficient energy
        let fee1 = try service.trc20TransferFee(
            accountUsage: accountUsage,
            parameters: parameters,
            gasLimit: BigInt(400),
            isNewAccount: false
        )
        #expect(fee1 == BigInt.zero)
        
        // Test case 2: Existing account with insufficient energy
        let fee2 = try service.trc20TransferFee(
            accountUsage: accountUsage,
            parameters: parameters,
            gasLimit: BigInt(600),
            isNewAccount: false
        )
        #expect(fee2 == BigInt(22000))
        
        // Test case 3: New account with sufficient energy
        let fee3 = try service.trc20TransferFee(
            accountUsage: accountUsage,
            parameters: parameters,
            gasLimit: BigInt(400),
            isNewAccount: true
        )
        #expect(fee3 == BigInt(200))
        
        // Test case 4: New account with insufficient energy
        let fee4 = try service.trc20TransferFee(
            accountUsage: accountUsage,
            parameters: parameters,
            gasLimit: BigInt(600),
            isNewAccount: true
        )
        #expect(fee4 == BigInt(22200))
    }
    
    @Test
    func testStakeFee() {
        let accountUsage = TronAccountUsage(freeNetUsed: 400, freeNetLimit: 1000, EnergyUsed: 0, EnergyLimit: 0)
        let accountUsage2 = TronAccountUsage(freeNetUsed: 500, freeNetLimit: 1000, EnergyUsed: 0, EnergyLimit: 0)
        
        // Test case 1: Stake with sufficient bandwidth
        let fee1 = service.stakeFee(
            accountUsage: accountUsage,
            type: .stake(validator: .mock()),
            totalStaked: BigInt(1000),
            inputValue: BigInt(100)
        )
        #expect(fee1 == BigInt.zero)
        
        // Test case 2: Stake with insufficient bandwidth
        let fee2 = service.stakeFee(
            accountUsage: accountUsage2,
            type: .stake(validator: .mock()),
            totalStaked: BigInt(1000),
            inputValue: BigInt(100)
        )
        #expect(fee2 == BigInt(560_000))
        
        // Test case 3: Unstake with sufficient bandwidth (partial unstake)
        let fee3 = service.stakeFee(
            accountUsage: accountUsage,
            type: .unstake(delegation: .mock(state: .active)),
            totalStaked: BigInt(1000),
            inputValue: BigInt(100)
        )
        #expect(fee3 == BigInt.zero)
        
        // Test case 4: Unstake with sufficient bandwidth (full unstake)
        let fee4 = service.stakeFee(
            accountUsage: accountUsage,
            type: .unstake(delegation: .mock(state: .active)),
            totalStaked: BigInt(1000),
            inputValue: BigInt(1000)
        )
        #expect(fee4 == BigInt.zero)
        
        [
            StakeType.rewards(validators: [.mock()]),
            StakeType.withdraw(delegation: .mock(state: .active)),
            StakeType.redelegate(delegation: .mock(state: .active), toValidator: .mock())
        ].forEach {
            let fee = service.stakeFee(
                accountUsage: accountUsage,
                type: $0,
                totalStaked: BigInt(1000),
                inputValue: BigInt(100)
            )
            #expect(fee == BigInt.zero)
        }
    }
}
