// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Blockchain
import Primitives
import GemAPI

struct StakeService {
    let store: StakeStore
    let chainServiceFactory: ChainServiceFactory
    let assetsService = GemAPIStaticService()

    func stakeApr(assetId: AssetId) throws -> Double? {
        return try store.getStakeApr(assetId: assetId)
    }
    
    func update(walletId: String, chain: Chain, address: String) async throws {
        let validators = try store.getValidators(assetId: chain.assetId)
        if validators.isEmpty {
            try await updateValidators(chain: chain)
            try await updateDelegations(walletId: walletId, chain: chain, address: address)
        } else {
            try await updateDelegations(walletId: walletId, chain: chain, address: address)
            try await updateValidators(chain: chain)
        }
    }
    
    func getActiveValidators(assetId: AssetId) throws -> [DelegationValidator] {
        try store.getValidators(assetId: assetId)
            .filter { $0.isActive && !$0.name.isEmpty }
    }

    func getRecipientAddress(chain: StakeChain?, type: AmountType, validatorId: String?) -> String? {
        guard let id = validatorId else {
            return nil
        }
        switch chain {
        case .cosmos, .osmosis, .injective, .sei, .celestia, .solana, .sui:
            return id
        case .smartChain:
            return StakeHub.address
        case .ethereum:
            // for Lido, it's stETH token address or withdrawal queue
            switch type {
            case .stake:
                return LidoContract.address
            case .unstake, .withdraw:
                return LidoContract.withdrawal
            default:
                fatalError()
            }
        case .none:
            fatalError()
        }
    }

    private func updateValidators(chain: Chain) async throws {
        let apr = try stakeApr(assetId: chain.assetId) ?? 0
        
        async let getValidators = chainServiceFactory.service(for: chain).getValidators(apr: apr)
        async let getValidatorsList = assetsService.getValidators(chain: chain)
        
        let (validators, validatorsList) = try await (
            getValidators,
            getValidatorsList.toMap { $0.id }
        )
        
        let updateValidators = validators.map {
            let name = $0.name.isEmpty ? validatorsList[$0.id]?.name ?? .empty : $0.name
            return DelegationValidator(
                chain: $0.chain,
                id: $0.id,
                name: name,
                isActive: $0.isActive,
                commision: $0.commision,
                apr: $0.apr
            )
        }
        
        try store.updateValidators(updateValidators)
    }
    
    private func updateDelegations(walletId: String, chain: Chain, address: String) async throws {
        let delegations = try await getDelegations(chain: chain, address: address)
        let existingDelegationsIds = try store.getDelegations(walletId: walletId, assetId: chain.assetId).map { $0.id }.asSet()
        let delegationsIds = delegations.map { $0.id }.asSet()
        let deleteDelegationsIds = existingDelegationsIds.subtracting(delegationsIds).asArray()
        
        // validators
        let validatorsIds = try store.getValidators(assetId: chain.assetId).map { $0.id }.asSet()
        let delegationsValidatorIds = delegations.map { $0.validatorId }.asSet()
        let missingValidatorIds = delegationsValidatorIds.subtracting(validatorsIds)
        
        //TODO: Might need to fetch in the future.
        if !missingValidatorIds.isEmpty {
            NSLog("missingValidatorIds \(missingValidatorIds)")
        }
        let updateDelegations = delegations.filter { validatorsIds.contains($0.validatorId) }
        
        try store.updateAndDelete(walletId: walletId, delegations: updateDelegations, deleteIds: deleteDelegationsIds)
    }
    
    private func getDelegations(chain: Chain, address: String) async throws -> [DelegationBase] {
        let service = chainServiceFactory.service(for: chain)
        return try await service.getStakeDelegations(address: address)
    }
}
